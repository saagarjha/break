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

	func save(username: String, password: String) -> Bool {
		let item: [String: AnyObject] = [kSecClass as String: kSecClassGenericPassword as String, kSecAttrAccount as String: username.dataUsingEncoding(NSUTF8StringEncoding)!, kSecValueData as String: password.dataUsingEncoding(NSUTF8StringEncoding)!]
		SecItemDelete(item)
		return SecItemAdd(item, nil) == noErr
	}

	func getPassword(username: String) -> String? {
		let item: [String: AnyObject] = [kSecClass as String: kSecClassGenericPassword as String, kSecAttrAccount as String: username, kSecReturnData as String: kCFBooleanTrue, kSecMatchLimit as String: kSecMatchLimitOne]
		var reference: AnyObject?
		if SecItemCopyMatching(item, &reference) == noErr {
			guard let reference = reference as? NSData else {
				return nil
			}
			return String(data: reference, encoding: NSUTF8StringEncoding)
		} else {
			return nil
		}
	}

	func removePassword(username: String) -> Bool {
		let item: [String: AnyObject] = [kSecClass as String: kSecClassGenericPassword, kSecAttrAccount as String: username]
		return SecItemDelete(item) == noErr
	}
}
