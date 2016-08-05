//
//  SchoolLoopKeychain.swift
//  break
//
//  Created by Saagar Jha on 1/25/16.
//  Copyright © 2016 Saagar Jha. All rights reserved.
//

import Foundation
import Security

class SchoolLoopKeychain {

	static let sharedInstance = SchoolLoopKeychain()

	func set(_ password: String, forUsername username: String) -> Bool {
		let item: [String: AnyObject] = [kSecClass as String: kSecClassGenericPassword as String, kSecAttrAccount as String: username.data(using: String.Encoding.utf8)!, kSecValueData as String: password.data(using: String.Encoding.utf8)!]
		SecItemDelete(item)
		return SecItemAdd(item, nil) == noErr
	}

	func getPassword(forUsername username: String) -> String? {
		let item: [String: AnyObject] = [kSecClass as String: kSecClassGenericPassword as String, kSecAttrAccount as String: username, kSecReturnData as String: kCFBooleanTrue, kSecMatchLimit as String: kSecMatchLimitOne]
		var reference: AnyObject?
		if SecItemCopyMatching(item, &reference) == noErr {
			guard let reference = reference as? Data else {
				return nil
			}
			return String(data: reference, encoding: String.Encoding.utf8)
		} else {
			return nil
		}
	}

	func removePassword(forUsername username: String) -> Bool {
		let item: [String: AnyObject] = [kSecClass as String: kSecClassGenericPassword, kSecAttrAccount as String: username]
		return SecItemDelete(item) == noErr
	}
}
