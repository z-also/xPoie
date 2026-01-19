import SwiftUI
import AuthenticationServices

struct SignInWithApple: View {
    let onSuccess: (ASAuthorization) -> Void
    let onFailure: (any Error) -> Void

    var body: some View {
        SignInWithAppleButton(
            onRequest: onRequest,
            onCompletion: onCompletion
        )
    }
    
    private func onRequest(req: ASAuthorizationAppleIDRequest) {
        req.requestedScopes = [.email, .fullName]
    }
    
    private func onCompletion(result: Result<ASAuthorization, any Error>) {
        switch result {
        case .failure(let error):
            onFailure(error)
        case .success(let authorization):
            onSuccess(authorization)
        }
    }
}
