extension APIs {
    static func auth() async throws -> IDL.AuthRsp {
        let params = IDL.AuthReq(
            token: ""
        )
        
        let url = "\(apiBase)/login/apple"
        
        return try await post(url, parameters: params) as IDL.AuthRsp
    }
}
