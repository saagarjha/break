//
//  SchoolLoopLoopMail.swift
//  break
//
//  Created by Saagar Jha on 1/22/16.
//  Copyright © 2016 Saagar Jha. All rights reserved.
//

import Foundation

class SchoolLoopLoopMail {
	var subject: String
	var sender: String
	var date: NSDate
	var ID: String

	var message: String = ""

	init(subject: String, sender: String, date: String, ID: String) {
		self.subject = subject
		self.sender = sender
		self.date = NSDate(timeIntervalSince1970: NSTimeInterval(date)! / 1000)
		self.ID = ID
	}
}
