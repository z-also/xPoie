extension APIs {
    struct IDL {
        struct AuthReq: Sendable, Codable {
            var token: String
        }
        
        struct AuthRsp: Sendable, Codable {
            var rsp: String
        }
    }
}
