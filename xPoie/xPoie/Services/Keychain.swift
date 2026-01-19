import Foundation
import Security

struct KeychainStore {
    let service: String
    
    enum Error: Swift.Error {
        case encodingFailed
        case invalidDataFormat
        case saveFailed(OSStatus)
        case loadFailed(OSStatus)
        case deleteFailed(OSStatus)
    }
    
    /// 保存字符串（会覆盖同 key 的旧值）
    func save(_ value: String, forKey key: String) throws {
        guard let data = value.data(using: .utf8) else {
            throw Error.encodingFailed
        }
        
        let query: [String: Any] = [
            kSecClass as String       : kSecClassGenericPassword,
            kSecAttrService as String : service,
            kSecAttrAccount as String : key,
            kSecValueData as String   : data,
            kSecAttrAccessible as String : kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]
        
        // 先删除旧记录，避免 duplicate item
        SecItemDelete(query as CFDictionary)
        
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw Error.saveFailed(status)
        }
    }
    
    /// 读取字符串（不存在返回 nil）
    func load(forKey key: String) throws -> String? {
        let query: [String: Any] = [
            kSecClass as String       : kSecClassGenericPassword,
            kSecAttrService as String : service,
            kSecAttrAccount as String : key,
            kSecReturnData as String  : true,
            kSecMatchLimit as String  : kSecMatchLimitOne
        ]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        
        if status == errSecItemNotFound {
            return nil
        }
        
        guard status == errSecSuccess else {
            throw Error.loadFailed(status)
        }
        
        guard let data = item as? Data,
              let string = String(data: data, encoding: .utf8) else {
            throw Error.invalidDataFormat
        }
        
        return string
    }
    
    /// 删除指定 key（不存在也不会抛错）
    func delete(forKey key: String) throws {
        let query: [String: Any] = [
            kSecClass as String       : kSecClassGenericPassword,
            kSecAttrService as String : service,
            kSecAttrAccount as String : key
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        if status != errSecSuccess && status != errSecItemNotFound {
            throw Error.deleteFailed(status)
        }
    }
}
