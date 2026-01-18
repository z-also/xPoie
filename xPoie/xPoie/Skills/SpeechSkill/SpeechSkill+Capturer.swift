import Foundation
import AVFoundation

extension SpeechSkill {
    class Capturer {
        struct AudioData: @unchecked Sendable {
            let buffer: AVAudioPCMBuffer
            let time: AVAudioTime
        }
        
        private let bufferSize: AVAudioFrameCount
        private lazy var captureEngine = AVAudioEngine()

        private var stream: AsyncStream<AudioData>.Continuation?

        init() {
            bufferSize = 2048
        }

        func start() async throws -> AsyncStream<AudioData> {
            guard await acquireAuthorization() else {
                throw Error.audioCaptureAccessDenied
            }
            
            captureEngine.reset()
            
            let inputNode = captureEngine.inputNode
            let format = inputNode.outputFormat(forBus: 0)

            inputNode.removeTap(onBus: 0)
            inputNode.installTap(onBus: 0, bufferSize: bufferSize, format: format, block: process)

            captureEngine.prepare()
            try captureEngine.start()

            return AsyncStream(AudioData.self, bufferingPolicy: .unbounded) { continuation in
                self.stream = continuation
            }
        }
        
        func stop() async throws {
            captureEngine.stop()
            captureEngine.inputNode.removeTap(onBus: 0)
            captureEngine.reset()
            stream?.finish()
            stream = nil
        }

        private func acquireAuthorization() async -> Bool {
            if AVCaptureDevice.authorizationStatus(for: .audio) == .authorized {
                return true
            }
            
            return await AVCaptureDevice.requestAccess(for: .audio)
        }
        
        private func process(buffer: AVAudioPCMBuffer, time: AVAudioTime) {
            let audioData = AudioData(buffer: buffer, time: time)
            self.stream?.yield(audioData)
        }
    }
}
