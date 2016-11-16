//
//  SchoolLoopComposedLoopMail.swift
//  break
//
//  Created by Saagar Jha on 11/14/16.
//  Copyright © 2016 Saagar Jha. All rights reserved.
//

import Foundation

@objc (SchoolLoopComposedLoopMail)
class SchoolLoopComposedLoopMail : NSObject {
	var subject: String
	var message: String
	var to: [SchoolLoopContact]
	var cc: [SchoolLoopContact]
	
	init(subject: String, message: String, to: [SchoolLoopContact], cc: [SchoolLoopContact]) {
		self.subject = subject
		self.message = message
		self.to = to
		self.cc = cc
	}
}
