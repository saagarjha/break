//
//  SchoolLoopAccount.swift
//  break
//
//  Created by Saagar Jha on 1/26/16.
//  Copyright © 2016 Saagar Jha. All rights reserved.
//

import Foundation

class SchoolLoopAccount {
	var username: String
	var password: String
	var fullName: String
	var studentID: String

	init(username: String, password: String, fullName: String, studentID: String) {
		self.username = username
		self.password = password
		self.fullName = fullName
		self.studentID = studentID
	}
}
