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
    var loggedIn: Bool = false

	init(username: String, password: String, fullName: String, studentID: String) {
		self.username = username
		self.password = password
		self.fullName = fullName
		self.studentID = studentID
		super.init()
	}

	required init?(coder aDecoder: NSCoder) {
		username = aDecoder.decodeObject(forKey: "username") as? String ?? ""
		password = SchoolLoop.sharedInstance.keychain.getPassword(forUsername: username) ?? ""
		fullName = aDecoder.decodeObject(forKey: "fullName") as? String ?? ""
		studentID = aDecoder.decodeObject(forKey: "studentID") as? String ?? ""
		super.init()
	}

	func encode(with aCoder: NSCoder) {
		aCoder.encode(username, forKey: "username")
		_ = SchoolLoop.sharedInstance.keychain.set(password, forUsername: username)
		aCoder.encode(fullName, forKey: "fullName")
		aCoder.encode(studentID, forKey: "studentID")
	}
}
