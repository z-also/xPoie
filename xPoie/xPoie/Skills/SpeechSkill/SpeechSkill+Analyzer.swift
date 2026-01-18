import Speech
import Foundation

extension SpeechSkill {
    class Analyzer {
        private var impl: SpeechAnalyzer?
        private var module: any SpeechModule
        private var inputStream: AsyncStream<AnalyzerInput>? = nil
        private var inputContinuation: AsyncStream<AnalyzerInput>.Continuation? = nil

        init(module: any SpeechModule) {
            self.module = module
        }
        
        static private func build(module: any SpeechModule) -> SpeechAnalyzer {
            SpeechAnalyzer(modules: [module],
                           options: .init(priority: .userInitiated,
                                          modelRetention: .processLifetime))
        }
        
        func preheat(audioFormat: AVAudioFormat?) async throws {
            //
        }
        
        func start() async throws -> AsyncStream<AnalyzerInput>.Continuation? {
            (inputStream, inputContinuation) = AsyncStream<AnalyzerInput>.makeStream()
            impl = Self.build(module: module)
            try await impl?.start(inputSequence: inputStream!)
            return inputContinuation
        }
        
        func stop() async throws {
            await impl?.cancelAndFinishNow()
        }
    }
}
