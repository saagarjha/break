//
//  SchoolLoopAccount.swift
//  break
//
//  Created by Saagar Jha on 1/26/16.
//  Copyright © 2016 Saagar Jha. All rights reserved.
//

import Foundation

/// Represents a single account.
@objc(SchoolLoopAccount)
public class SchoolLoopAccount: NSObject, NSSecureCoding {
	/// The username for this account.
	public var username: String

	/// The password for this account.
	public var password: String

	/// The full name of the user associated with this account.
	public var fullName: String
	/// The student ID of the user associated with this account. Note that this
	/// is the ID School Loop uses to identify users; it may differ from the
	/// student ID that many institutions give their students.
	public var studentID: String

	/// The hashed password associated with this account, for School Loop POST
	/// requests.
	public var hashedPassword: String

	/// The email of the user associated with this account.
	public var email: String


	/// A Boolean that indicates whether this account is logged in.
	public var isLoggedIn: Bool = false


	/// This class supports secure coding.
	public static var supportsSecureCoding = true


	/// Create a new account with the specified values.
	///
	/// - Parameters:
	///   - username: The username for this account
	///   - password: The password for this account
	///   - fullName: The full name of the user associated with this account
	///   - studentID: The student ID of the user associated with this account
	///   - hashedPassword: The hashed password associated with this account
	///   - email: The email of the user associated with this account
	public init(username: String, password: String, fullName: String, studentID: String, hashedPassword: String, email: String) {
		self.username = username
		self.password = password
		self.fullName = fullName
		self.studentID = studentID
		self.hashedPassword = hashedPassword
		self.email = email
		super.init()
	}

	/// `NSCoding` initializer. You probably don't want to invoke this directly.
	public required init?(coder aDecoder: NSCoder) {
		#if os(iOS)
			Logger.log("Beginning account decoding")
		#endif
		username = aDecoder.decodeObject(of: NSString.self, forKey: "username") as String? ?? ""
		password = SchoolLoop.sharedInstance.keychain.getPassword(forUsername: username) ?? ""
		if password.isEmpty {
			#if os(iOS)
				Logger.log("Failed to get password")
			#endif
		}
		fullName = aDecoder.decodeObject(of: NSString.self, forKey: "fullName") as String? ?? ""
		studentID = aDecoder.decodeObject(of: NSString.self, forKey: "studentID") as String? ?? ""
		hashedPassword = aDecoder.decodeObject(of: NSString.self, forKey: "hashedPassword") as String? ?? ""
		email = aDecoder.decodeObject(of: NSString.self, forKey: "email") as String? ?? ""
		super.init()
	}

	/// `NSCoding` encoding. You probably don't want to invoke this directly.
	public func encode(with aCoder: NSCoder) {
		aCoder.encode(username, forKey: "username")
		let set = SchoolLoop.sharedInstance.keychain.addPassword(password, forUsername: username)
		if !set {
			#if os(iOS)
				Logger.log("Failed to set password")
			#endif
		}
		aCoder.encode(fullName, forKey: "fullName")
		aCoder.encode(studentID, forKey: "studentID")
		aCoder.encode(hashedPassword, forKey: "hashedPassword")
		aCoder.encode(email, forKey: "email")
	}
}
