//
//  KeychainStore.swift
//  MinimalTimer
//

import Foundation
import Security

/// 결제 권한 등 변조되면 안 되는 민감한 로컬 상태 값을 Keychain에 암호화 저장하는 저장소.
/// UserDefaults 평문 저장을 대체한다.
struct KeychainStore {
    private let service: String

    init(service: String = Bundle.main.bundleIdentifier ?? "app.stannum.minitime") {
        self.service = service
    }

    func setBool(_ value: Bool, forKey key: String) {
        setData(Data([value ? 1 : 0]), forKey: key)
    }

    func bool(forKey key: String) -> Bool {
        guard let data = data(forKey: key), let firstByte = data.first else { return false }
        return firstByte == 1
    }

    func data(forKey key: String) -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard status == errSecSuccess else { return nil }
        return result as? Data
    }

    func setData(_ data: Data, forKey key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]
        let attributes: [String: Any] = [kSecValueData as String: data]

        let updateStatus = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
        guard updateStatus == errSecItemNotFound else { return }

        var newItem = query
        newItem[kSecValueData as String] = data
        newItem[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlock
        SecItemAdd(newItem as CFDictionary, nil)
    }

    func removeValue(forKey key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]
        SecItemDelete(query as CFDictionary)
    }
}
