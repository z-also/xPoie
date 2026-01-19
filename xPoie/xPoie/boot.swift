import Foundation

@MainActor
let accountService: AccountService = {
    let keychain = KeychainStore(
        service: (Bundle.main.bundleIdentifier ?? "default") + ".security"
    )
    let service = AccountService(keychain: keychain)
    Task { await service.checkLoginStatus() }
    return service
}()
