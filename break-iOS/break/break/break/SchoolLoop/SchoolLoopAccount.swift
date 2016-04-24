//
//  SchoolLoopAccount.swift
//  break
//
//  Created by Saagar Jha on 1/26/16.
//  Copyright © 2016 Saagar Jha. All rights reserved.
//

import Foundation

class SchoolLoopAccount: NSObject, NSCoding {
	var username: String
	var password: String
	var fullName: String
	var studentID: String

	init(username: String, password: String, fullName: String, studentID: String) {
		self.username = username
		self.password = password
		self.fullName = fullName
		self.studentID = studentID
		super.init()
	}

	required init?(coder aDecoder: NSCoder) {
		username = aDecoder.decodeObjectForKey("username") as? String ?? ""
//		password = aDecoder.decodeObjectForKey("password") as? String ?? ""
		password = SchoolLoopKeychain.sharedInstance.getPasswordForUsername(username) ?? ""
		fullName = aDecoder.decodeObjectForKey("fullName") as? String ?? ""
		studentID = aDecoder.decodeObjectForKey("studentID") as? String ?? ""
		super.init()
	}

	func encodeWithCoder(aCoder: NSCoder) {
		aCoder.encodeObject(username, forKey: "username")
//		aCoder.encodeObject(password, forKey: "password")
		SchoolLoopKeychain.sharedInstance.setPassword(password, forUsername: username)
		aCoder.encodeObject(fullName, forKey: "fullName")
		aCoder.encodeObject(studentID, forKey: "studentID")
	}
}
