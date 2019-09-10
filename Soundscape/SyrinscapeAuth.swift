//
//  SyrinscapeAuth.swift
//  Soundscape
//
//  Created by Scott James Remnant on 9/5/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import Foundation

final class SyrinscapeAuth {
    static let shared = SyrinscapeAuth()

    let secItemServer = "syrinscape.com"
    let secItemService = "com.netsplit.Soundscape.client"

    // MARK: Username and Password

    func getUsernameAndPassword() -> (String, String)? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassInternetPassword,
            kSecAttrServer as String: secItemServer,
            kSecReturnAttributes as String: true,
            kSecReturnData as String: true
        ]

        var result: AnyObject?
        let err = SecItemCopyMatching(query as CFDictionary, &result)
        guard err == errSecSuccess else {
            if err != errSecItemNotFound {
                print("Keychain Error retrieving login credentials: \(err)")
            }
            return nil
        }

        if let result = result as? [String: Any],
            let username = result[kSecAttrAccount as String] as? String,
            let data = result[kSecValueData as String] as? Data,
            let password = String(data: data, encoding: .utf8)
        {
            return (username, password)
        } else {
            print("Keychain returned result without login credentials")
            return nil
        }
    }

    func save(username: String, password: String) throws {
        var query: [String: Any] = [
            kSecClass as String: kSecClassInternetPassword,
            kSecAttrServer as String: secItemServer
        ]

        let attributes: [String: Any] = [
            kSecAttrLabel as String: "Syrinscape",
            kSecAttrAccount as String: username,
            kSecValueData as String: password.data(using: .utf8)!
        ]

        var err = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
        if err == errSecItemNotFound {
            query.merge(attributes, uniquingKeysWith: { a, b in b })
            err = SecItemAdd(query as CFDictionary, nil)
        }
        guard err == errSecSuccess else {
            throw NSError(domain: NSOSStatusErrorDomain, code: Int(err), userInfo: nil)
        }
    }

    // MARK: UUID and Key

    func getUUIDAndKey() -> (String, String)? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: secItemService,
            kSecReturnAttributes as String: true,
            kSecReturnData as String: true
        ]

        var result: AnyObject?
        let err = SecItemCopyMatching(query as CFDictionary, &result)
        guard err == errSecSuccess else {
            if err != errSecItemNotFound {
                print("Keychain Error retrieving auth credentials: \(err)")
            }
            return nil
        }

        if let result = result as? [String: Any],
            let uuid = result[kSecAttrAccount as String] as? String,
            let data = result[kSecValueData as String] as? Data,
            let key = String(data: data, encoding: .utf8)
        {
            return (uuid, key)
        } else {
            print("Keychain returned result without auth credentials")
            return nil
        }
    }

    func save(uuid: String, key: String) throws {
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: secItemService
        ]

        let attributes: [String: Any] = [
            kSecAttrLabel as String: "Syrinscape Authorization",
            kSecAttrAccount as String: uuid,
            kSecValueData as String: key.data(using: .utf8)!
        ]

        var err = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
        if err == errSecItemNotFound {
            query.merge(attributes, uniquingKeysWith: { a, b in b })
            err = SecItemAdd(query as CFDictionary, nil)
        }
        guard err == errSecSuccess else {
            throw NSError(domain: NSOSStatusErrorDomain, code: Int(err), userInfo: nil)
        }
    }
}
