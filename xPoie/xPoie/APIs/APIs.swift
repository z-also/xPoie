import Alamofire

struct APIs {
    static let apiBase = "http://localhost:8787"

    static func get<T: Codable & Sendable, T2: Codable & Sendable>(
        _ url: URLConvertible,
        parameters: T2? = nil,
        headers: HTTPHeaders? = nil,
        encoder: ParameterEncoder = URLEncodedFormParameterEncoder.default
    ) async throws -> T {
        return try await AF.request(
            url,
            method: .get,
            parameters: parameters,
            encoder: encoder
        ).serializingDecodable(T.self).value
    }

    static func post<T: Codable & Sendable, T2: Codable & Sendable>(
        _ url: URLConvertible,
        parameters: T2? = nil,
        headers: HTTPHeaders? = nil,
        encoder: ParameterEncoder = JSONParameterEncoder.default
    ) async throws -> T {
        return try await AF.request(
            url,
            method: .post,
            parameters: parameters,
            encoder: encoder
        ).serializingDecodable(T.self).value
    }
}
