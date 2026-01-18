import Speech
import Foundation

class SpeechSkill {
    private var capturer: Capturer?
    private var analyzer: Analyzer?
    private var transcriber: (any Transcriber)?
    
    private var converter = BufferConverter()
    private var bestAvailableAudioFormat: AVAudioFormat? = nil
    
    private var status: Status = .none

    init() {}
    
    func setup() async throws {
        do {
            transcriber = try await Speech(locale: Locale.current)
        } catch {
            transcriber = try await Dictation(locale: Locale.current)
        }
        
        guard let transcriber = transcriber else {
            throw Error.transcriberNotAvailable
        }
        
        let capturer = Capturer()
        let analyzer = Analyzer(module: transcriber.module)
        let bestAvailableAudioFormat = await SpeechAnalyzer.bestAvailableAudioFormat(
            compatibleWith: [transcriber.module]
        )

        self.capturer = capturer
        self.analyzer = analyzer
        self.transcriber = transcriber
        self.bestAvailableAudioFormat = bestAvailableAudioFormat
        
        try await ensure(transcriber: transcriber)
        try await analyzer.preheat(audioFormat: bestAvailableAudioFormat)
    }
    
    func start(consume: @escaping LiveStream) async throws {
        try await setup()
        
        guard let capturer = capturer,
              let analyzer = analyzer,
              let transcriber = transcriber else {
            return
        }

        status = .working
        transcriber.start(consume: consume)
        
        guard let analyzerStream = try await analyzer.start() else {
            throw Error.analyzerStreamUnavailable
        }
        
        for await audioData in try await capturer.start() {
            let buffer = try converter.convertBuffer(audioData.buffer,
                                                     to: bestAvailableAudioFormat!)
            let input = AnalyzerInput(buffer: buffer)
            analyzerStream.yield(input)
        }
    }
    
    func stop() async throws {
        try await capturer?.stop()
        try await analyzer?.stop()
        try await transcriber?.stop()
    }
    
    deinit {
        
    }
    
    private func ensure(transcriber: any Transcriber) async throws {
        if await transcriber.isLocalInstalled() {
            return
        }
        
        if let installationRequest = try await AssetInventory.assetInstallationRequest(supporting: [transcriber.module]) {
            try await installationRequest.downloadAndInstall()
        }
    }
    
    nonisolated(unsafe) static var shared = SpeechSkill()
}
