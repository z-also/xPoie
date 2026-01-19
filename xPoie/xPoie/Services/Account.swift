import Foundation
import Observation
import AuthenticationServices

@Observable
@MainActor
final class AccountService {
    // 公开状态：是否已登录（SwiftUI 可直接绑定）
    var isLoggedIn: Bool = false
    
    // 内部存储 userID 的 key（固定）
    private let userIDKey = "appleUserIdentifier"
    
    private let keychain: KeychainStore
    
    init(keychain: KeychainStore) {
        self.keychain = keychain
        // 初始化时自动检查一次状态
        Task { await checkLoginStatus() }
    }
    
    // MARK: - 登录成功后调用（从 SignInWithAppleButton 的 onCompletion 传入）
    func handleSuccessfulLogin(authorization: ASAuthorization) throws {
        if let credential = authorization.credential as? ASAuthorizationAppleIDCredential {
            let userID = credential.user
            
            try keychain.save(userID, forKey: userIDKey)
            isLoggedIn = true
            
            print("AccountService: 登录成功，已保存 userID 到 Keychain")
            // 登录成功后，视图会因为 isLoggedIn 变化自动切换到 MainContentView
        }
        
        // 可选：如果有后端，可以在这里发送 identityToken 注册/换取 session token
        // if let tokenData = credential.identityToken { ... }
    }
    
    // MARK: - 检查登录状态（App 启动、场景激活、需要验证时调用）
    func checkLoginStatus() async {
        do {
            guard let userID = try keychain.load(forKey: userIDKey) else {
                // Keychain 中没有 → 未登录
                isLoggedIn = false
                return
            }
            
            let provider = ASAuthorizationAppleIDProvider()
            
            let credentialState = try await withCheckedThrowingContinuation {
                (continuation: CheckedContinuation<ASAuthorizationAppleIDProvider.CredentialState, Error>) in
                
                provider.getCredentialState(forUserID: userID) { state, error in
                    if let error {
                        continuation.resume(throwing: error)
                    } else {
                        continuation.resume(returning: state)
                    }
                }
            }
            
            switch credentialState {
            case .authorized:
                isLoggedIn = true
                
            case .revoked, .notFound, .transferred:
                try? keychain.delete(forKey: userIDKey)
                isLoggedIn = false
                
            @unknown default:
                isLoggedIn = false
            }
            
        } catch {
            print("AccountService: 检查登录状态失败 - \(error.localizedDescription)")
            isLoggedIn = false
        }
    }
    
    func signOut() {
        do {
            try keychain.delete(forKey: userIDKey)
            isLoggedIn = false
            print("AccountService: 已登出并清除 Keychain")
        } catch {
            print("AccountService: 登出时 Keychain 删除失败 - \(error)")
            isLoggedIn = false  // 即使失败也强制设为未登录
        }
    }
    
    var currentUserID: String? {
        try? keychain.load(forKey: userIDKey)
    }
}
