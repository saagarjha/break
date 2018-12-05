//
//  SchoolLoopKeychain.swift
//  break
//
//  Created by Saagar Jha on 1/25/16.
//  Copyright © 2016 Saagar Jha. All rights reserved.
//

import Foundation
import Security

/// A convenience wrapper for storing sensitive information.
public struct SchoolLoopKeychain {
	/// A singleton for use throughout a project to manage a single keychain.
	static let sharedInstance = SchoolLoopKeychain()

	/// Adds the specified password for the the specified username to this
	/// keychain.
	///
	/// - Parameters:
	///   - password: The password to add
	///   - username: The username to add the password under
	/// - Returns: Whether the password was set successfully
	public func addPassword(_ password: String, forUsername username: String) -> Bool {
		let item: CFDictionary = [
			kSecClass as String: kSecClassGenericPassword as String,
			kSecAttrAccount as String: Data(username.utf8),
			kSecValueData as String: Data(password.utf8),
		] as CFDictionary
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

	/// Retrieves the password for the specified username from this keychain.
	///
	/// - Parameter username: The username under which the password is stored
	/// - Returns: The password stored under the specified username, if any
	public func getPassword(forUsername username: String) -> String? {
		let item: CFDictionary = [
			kSecClass as String: kSecClassGenericPassword as String,
			kSecAttrAccount as String: username,
			kSecReturnData as String: kCFBooleanTrue,
		] as CFDictionary
		var reference: AnyObject?
		let error = SecItemCopyMatching(item, &reference)
		if error == noErr {
			guard let reference = reference as? Data else {
				#if os(iOS)
					Logger.log("Failed to read password")
				#endif
				return nil
			}
			return String(data: reference, encoding: .utf8)
		} else {
			#if os(iOS)
				Logger.log("Failed to read password: \(error)")
			#endif
			return nil
		}
	}

	/// Removes the username/password entry for the specified username from this
	/// keychain.
	///
	/// - Parameter username: The key for the username/password entry to remove
	/// - Returns: Whether the username/password entry was removed successfully
	public func removePassword(forUsername username: String) -> Bool {
		let item: CFDictionary = [
			kSecClass as String: kSecClassGenericPassword,
			kSecAttrAccount as String: username,
		] as CFDictionary
		return SecItemDelete(item) == noErr
	}
}
