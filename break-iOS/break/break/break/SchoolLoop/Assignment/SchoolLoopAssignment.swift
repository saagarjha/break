//
//  SchoolLoopAssignment.swift
//  break
//
//  Created by Saagar Jha on 1/20/16.
//  Copyright © 2016 Saagar Jha. All rights reserved.
//

import Foundation

class SchoolLoopAssignment {
	var title: String
	var description: String
	var courseName: String
	var dueDate: NSDate
	var links: [(title: String, URL: String)]
	var iD: String

	init(title: String, description: String, courseName: String, dueDate: String, links: [(title: String, URL: String)], iD: String) {
		self.title = title
		self.description = description
		self.courseName = courseName
		self.dueDate = NSDate(timeIntervalSince1970: NSTimeInterval(dueDate)! / 1000)
		self.links = links
		self.iD = iD
	}
    
    func setDueDate(dueDate: String) {
        self.dueDate = NSDate(timeIntervalSince1970: NSTimeInterval(dueDate)! / 1000)
    }
}
