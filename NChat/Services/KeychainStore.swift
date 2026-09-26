import Foundation
import Security

enum KeychainStore {
    private static let service = "com.nashmei.NChat"
    private static let account = "nvidia-api-key"
    static func save(_ value: String) throws {
        delete()
        let data = Data(value.utf8)
        let q: [CFString: Any] = [kSecClass:kSecClassGenericPassword,kSecAttrService:service,kSecAttrAccount:account,kSecValueData:data,kSecAttrAccessible:kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly]
        let status = SecItemAdd(q as CFDictionary, nil)
        guard status == errSecSuccess else { throw NSError(domain:NSOSStatusErrorDomain, code:Int(status)) }
    }
    static func read() -> String {
        var result: CFTypeRef?
        let q: [CFString: Any] = [kSecClass:kSecClassGenericPassword,kSecAttrService:service,kSecAttrAccount:account,kSecReturnData:true,kSecMatchLimit:kSecMatchLimitOne]
        guard SecItemCopyMatching(q as CFDictionary, &result) == errSecSuccess, let data = result as? Data else { return "" }
        return String(decoding:data, as:UTF8.self)
    }
    static func delete() {
        SecItemDelete([kSecClass:kSecClassGenericPassword,kSecAttrService:service,kSecAttrAccount:account] as CFDictionary)
    }
}
