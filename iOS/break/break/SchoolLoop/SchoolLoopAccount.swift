//
//  SchoolLoopAccount.swift
//  break
//
//  Created by Saagar Jha on 1/26/16.
//  Copyright © 2016 Saagar Jha. All rights reserved.
//

import Foundation

@objc(SchoolLoopAccount)
class SchoolLoopAccount: NSObject, NSCoding {
	var username: String
	var password: String
	var fullName: String
	var studentID: String
	var hashedPassword: String
	var loggedIn: Bool = false

	init(username: String, password: String, fullName: String, studentID: String, hashedPassword: String) {
		self.username = username
		self.password = password
		self.fullName = fullName
		self.studentID = studentID
		self.hashedPassword = hashedPassword
		super.init()
	}

	required init?(coder aDecoder: NSCoder) {
		#if os(iOS)
			Logger.log("Beginning account decoding")
		#endif
		username = aDecoder.decodeObject(forKey: "username") as? String ?? ""
		password = SchoolLoop.sharedInstance.keychain.getPassword(forUsername: username) ?? ""
		if password.isEmpty {
			#if os(iOS)
				Logger.log("Failed to get password")
			#endif
		}
		fullName = aDecoder.decodeObject(forKey: "fullName") as? String ?? ""
		studentID = aDecoder.decodeObject(forKey: "studentID") as? String ?? ""
		hashedPassword = aDecoder.decodeObject(forKey: "hashedPassword") as? String ?? ""
		super.init()
	}

	func encode(with aCoder: NSCoder) {
		aCoder.encode(username, forKey: "username")
		let set = SchoolLoop.sharedInstance.keychain.set(password, forUsername: username)
		if !set {
			#if os(iOS)
				Logger.log("Failed to set password")
			#endif
		}
		aCoder.encode(fullName, forKey: "fullName")
		aCoder.encode(studentID, forKey: "studentID")
		aCoder.encode(hashedPassword, forKey: "hashedPassword")
	}
}
