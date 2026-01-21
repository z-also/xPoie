import Foundation

extension Llmx {
    public final class Downloader: NSObject {
        enum State {
            case none
            case downloading(Double)
            case completed(URL)
            case failed(Swift.Error)
        }
        
        public typealias ProgressHandler = @Sendable (Double) -> Void
        public typealias ResultHandler   = @Sendable (Result<URL, Swift.Error>) -> Void

        private var state = State.none
        private var session: URLSession!
        private var completion: ResultHandler?
        private var progressHandler: ProgressHandler?

        private var resumeData: Data?
        private let destination: URL
        private var downloadTask: URLSessionDownloadTask?

        public init(destination: URL) {
            self.destination = destination
            super.init()
            let config = URLSessionConfiguration.default
            session = URLSession(configuration: config, delegate: self, delegateQueue: OperationQueue())
        }
        
        deinit {
            session.invalidateAndCancel()
        }
        
        public func start(url: URL, progress: @escaping ProgressHandler, completion: @escaping ResultHandler) {
            self.completion = completion
            self.progressHandler = progress
            
            if checkIfAlreadyDownloaded(url: url) {
                makeSuccess()
                return
            }

            if let resumeData = self.resumeData {
                downloadTask = session.downloadTask(withResumeData: resumeData)
            } else {
                var request = URLRequest(url: url)
                request.timeoutInterval = 60
                
                if let partialSize = getPartialFileSize(), partialSize > 0 {
                    request.setValue("bytes=\(partialSize)-", forHTTPHeaderField: "Range")
                }
                
                downloadTask = session.downloadTask(with: request)
            }
            
            downloadTask?.resume()
        }
        
        // TODO：加个参数控制要不要保存持久化 resumeDaa
        public func pause() {
            downloadTask?.cancel { [weak self] data in
                self?.resumeData = data
                self?.downloadTask = nil
            }
        }
        
        public func cancel() {
            pause()
        }
        
        private func cleanup() {
            downloadTask = nil
        }
        
        // 辅助：获取本地部分文件大小
        private func getPartialFileSize() -> Int64? {
            guard FileManager.default.fileExists(atPath: destination.path) else { return nil }
            do {
                let attrs = try FileManager.default.attributesOfItem(atPath: destination.path)
                return attrs[.size] as? Int64
            } catch {
                return nil
            }
        }
        
        private func getExpectedSize(from url: URL, completion: @escaping (Int64?) -> Void) {
            var request = URLRequest(url: url)
            request.httpMethod = "HEAD"
            let task = session.dataTask(with: request) { data, response, error in
                if let httpResponse = response as? HTTPURLResponse,
                   let contentLength = httpResponse.allHeaderFields["Content-Length"] as? String {
                    completion(Int64(contentLength))
                } else {
                    completion(nil)
                }
            }
            task.resume()
        }
        
        private func checkIfAlreadyDownloaded(url: URL) -> Bool {
            var isCompleted = false
            let semaphore = DispatchSemaphore(value: 0)
            
            getExpectedSize(from: url) { expectedSize in
                if let expected = expectedSize,
                   let localSize = self.getPartialFileSize(),
                   localSize == expected {
                    isCompleted = true
                }
                semaphore.signal()
            }
            
            semaphore.wait()
            return isCompleted
        }
        
        private func makeSuccess() {
            state = .completed(destination)
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.progressHandler?(1.0)
                self.completion?(.success(self.destination))
                self.cleanup()
            }
        }
        
        private func makeFailure(error: Swift.Error) {
            state = .failed(error)
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.completion?(.failure(error))
                self.cleanup()
            }
        }
    }
}

extension Llmx.Downloader: URLSessionDelegate, URLSessionDownloadDelegate {
    public func urlSession(_ session: URLSession,
                           downloadTask: URLSessionDownloadTask,
                           didWriteData bytesWritten: Int64,
                           totalBytesWritten: Int64,
                           totalBytesExpectedToWrite: Int64) {
        guard totalBytesExpectedToWrite > 0 else { return }
        let progress = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
        DispatchQueue.main.async { [weak self] in
            self?.progressHandler?(max(0, min(1, progress)))
        }
    }
    
    public func urlSession(_ session: URLSession,
                           downloadTask: URLSessionDownloadTask,
                           didFinishDownloadingTo location: URL) {
        do {
            try FileManager.default.moveItem(at: location, to: destination)
            makeSuccess()
        } catch {
            makeFailure(error: error)
        }
    }
    
    public func urlSession(_ session: URLSession,
                           task: URLSessionTask,
                           didCompleteWithError error: Swift.Error?) {
        guard let error = error as NSError? else { return }
        
        if error.code == NSURLErrorCancelled {
            return
        }
        
        
        // 改进2: 错误处理更细致
//        let customError: Error
//        switch error.code {
//        case NSURLErrorNotConnectedToInternet, NSURLErrorNetworkConnectionLost:
//            customError = NSError(domain: "Downloader", code: error.code, userInfo: [NSLocalizedDescriptionKey: "网络连接中断，可稍后重试"])
//        case NSURLErrorTimedOut:
//            customError = NSError(domain: "Downloader", code: error.code, userInfo: [NSLocalizedDescriptionKey: "请求超时，请检查网络"])
//        default:
//            // 假设 resumeData 失效（e.g., 服务器不支持），fallback 从头下载
//            if self.resumeData != nil {
//                self.resumeData = nil  // 清空无效 resumeData
//                // 可选：在这里自动重启 start()，但为避免循环，交给调用者
//                customError = NSError(domain: "Downloader", code: error.code, userInfo: [NSLocalizedDescriptionKey: "续传失败，从头开始下载"])
//            } else {
//                customError = error
//            }
//        }
        
        makeFailure(error: error)
    }
}
