import Speech
import Foundation

extension SpeechSkill {
    typealias LiveStream = @MainActor (
        AttributedString, AttributedString, Bool
    ) -> Void
    
    protocol Transcriber<Impl> where Impl: SpeechModule {
        associatedtype Impl
        var module: Impl { get }
        var locale: Locale { get }
        func isLocalInstalled() async -> Bool
        func start(consume: @escaping LiveStream) -> Void
        func stop() async throws -> Void
    }
    
    class Dictation: Transcriber {
        let locale: Locale
        let module: DictationTranscriber
        
        private var recognizer: Task<(), Swift.Error>?

        init(locale: Locale) async throws {
            guard let locale = await DictationTranscriber.supportedLocale(equivalentTo: locale) else {
                throw Error.localeNotSupported
            }
            
            self.locale = locale
            
            self.module = DictationTranscriber(locale: locale,
                                        contentHints: [],
                                        transcriptionOptions: [],
                                        reportingOptions: [.volatileResults],
                                        attributeOptions: [.audioTimeRange])
        }
        
        func isLocalInstalled() async -> Bool {
            (await DictationTranscriber.installedLocales).contains(locale)
        }
        
        func start(consume: @escaping LiveStream) {
            let module = self.module
            recognizer = Task {
                do {
                    var volatile: AttributedString = ""
                    var finalized: AttributedString = ""
                    
                    for try await case let result in module.results {
                        let text = result.text
                        if result.isFinal {
                            volatile = ""
                            finalized += text
                            await consume(text, volatile, true)
                        } else {
                            volatile = text
                            await consume(text, volatile, false)
                        }
                    }
                } catch {
                    print("speech recognition failed")
                }
            }
        }
        
        func stop() async throws {
            recognizer?.cancel()
            recognizer = nil
        }
    }
    
    class Speech: Transcriber {
        let locale: Locale
        let module: SpeechTranscriber
        
        private var recognizer: Task<(), Swift.Error>?

        init(locale: Locale) async throws {
            guard SpeechTranscriber.isAvailable else {
                throw Error.transcriberNotAvailable
            }
            
            guard let locale = await SpeechTranscriber.supportedLocale(equivalentTo: locale) else {
                throw Error.localeNotSupported
            }
            
            self.locale = locale
            
            self.module = SpeechTranscriber(locale: locale,
                                            transcriptionOptions: [],
                                            reportingOptions: [.volatileResults],
                                            attributeOptions: [.audioTimeRange])
        }
        
        func isLocalInstalled() async -> Bool {
            (await SpeechTranscriber.installedLocales).contains(locale)
        }
        
        func start(consume: @escaping LiveStream) {
            let module = self.module
            recognizer = Task {
                do {
                    for try await case let result in module.results {
                        let text = result.text
                        print("====", text)
                    }
                } catch {
                    print("speech recognition failed")
                }
            }
        }
        
        func stop() async throws {
            recognizer?.cancel()
            recognizer = nil
        }
    }
}
