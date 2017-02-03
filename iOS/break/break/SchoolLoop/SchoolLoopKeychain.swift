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
		let item: CFDictionary = [kSecClass as String: kSecClassGenericPassword as String, kSecAttrAccount as String: username.data(using: String.Encoding.utf8)!, kSecValueData as String: password.data(using: String.Encoding.utf8)!] as CFDictionary
		var status = SecItemDelete(item)
		if status != noErr {
			#if os(iOS)
				Logger.log("Deleted?: \(status)")
			#endif
		}
		status = SecItemAdd(item, nil)
		if status != noErr {
		#if os(iOS)
			Logger.log("Added?: \(status)")
		#endif
		}
		return status == noErr
	}

	func getPassword(forUsername username: String) -> String? {
		let item: CFDictionary = [kSecClass as String: kSecClassGenericPassword as String, kSecAttrAccount as String: username, kSecReturnData as String: kCFBooleanTrue, kSecMatchLimit as String: kSecMatchLimitOne] as CFDictionary
		var reference: AnyObject?
		let error = SecItemCopyMatching(item, &reference)
		if error == noErr {
			guard let reference = reference as? Data else {
				#if os(iOS)
					Logger.log("Failed to read password")
				#endif
				return nil
			}
			return String(data: reference, encoding: String.Encoding.utf8)
		} else {
			#if os(iOS)
				Logger.log("Failed to read password: \(error)")
			#endif
			return nil
		}
	}

	func removePassword(forUsername username: String) -> Bool {
		let item: CFDictionary = [kSecClass as String: kSecClassGenericPassword, kSecAttrAccount as String: username] as CFDictionary
		return SecItemDelete(item) == noErr
	}
}
