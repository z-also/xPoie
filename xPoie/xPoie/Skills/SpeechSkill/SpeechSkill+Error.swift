extension SpeechSkill {
    enum Status {
        case none
        case ready
        case initializing
        case working
    }
    
    enum Error: Swift.Error {
        case localeNotSupported
        case transcriberNotAvailable
        case audioCaptureAccessDenied
        case analyzerStreamUnavailable
        case audioConverterCreationFailed
        case failedToConvertBuffer(String?)
    }
}
