//
//  SchoolLoopAssignment.swift
//  break
//
//  Created by Saagar Jha on 1/20/16.
//  Copyright © 2016 Saagar Jha. All rights reserved.
//

import Foundation

@objc(SchoolLoopAssignment)
class SchoolLoopAssignment: NSObject, NSCoding {
	var title: String
	var assignmentDescription: String
	var courseName: String
	var dueDate: NSDate
	var links: [(title: String, URL: String)]
	var iD: String

	init(title: String, assignmentDescription: String, courseName: String, dueDate: String, links: [(title: String, URL: String)], iD: String) {
		self.title = title
		self.assignmentDescription = assignmentDescription
		self.courseName = courseName
		self.dueDate = NSDate(timeIntervalSince1970: NSTimeInterval(dueDate)! / 1000)
		self.links = links
		self.iD = iD
		super.init()
	}

	func setNewDueDate(dueDate: String) {
		self.dueDate = NSDate(timeIntervalSince1970: NSTimeInterval(dueDate)! / 1000)
	}

	required init?(coder aDecoder: NSCoder) {
		title = aDecoder.decodeObjectForKey("title") as? String ?? ""
		assignmentDescription = aDecoder.decodeObjectForKey("assignmentDescription") as? String ?? ""
		courseName = aDecoder.decodeObjectForKey("courseName") as? String ?? ""
		dueDate = aDecoder.decodeObjectForKey("dueDate") as? NSDate ?? NSDate.distantPast()
		links = aDecoder.decodeObjectForKey("links") as? [(title: String, URL: String)] ?? []
		iD = aDecoder.decodeObjectForKey("iD") as? String ?? ""
		super.init()
	}

	func encodeWithCoder(aCoder: NSCoder) {
		aCoder.encodeObject(title, forKey: "title")
		aCoder.encodeObject(description, forKey: "assignmentDescription")
		aCoder.encodeObject(courseName, forKey: "courseName")
		aCoder.encodeObject(dueDate, forKey: "dueDate")
		aCoder.encodeObject(links as? AnyObject, forKey: "links")
		aCoder.encodeObject(iD, forKey: "iD")
	}
}
