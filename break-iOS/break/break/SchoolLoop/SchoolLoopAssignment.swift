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
	var dueDate: Date
	var links: [(title: String, URL: String)]
	var iD: String

	init(title: String, assignmentDescription: String, courseName: String, dueDate: String, links: [(title: String, URL: String)], iD: String) {
		self.title = title
		self.assignmentDescription = assignmentDescription
		self.courseName = courseName
		self.dueDate = Date(timeIntervalSince1970: (TimeInterval(dueDate) ?? 0) / 1000)
		self.links = links
		self.iD = iD
		super.init()
	}

	func set(newDueDate dueDate: String) {
		self.dueDate = Date(timeIntervalSince1970: TimeInterval(dueDate)! / 1000)
	}

	required init?(coder aDecoder: NSCoder) {
		title = aDecoder.decodeObject(forKey: "title") as? String ?? ""
		assignmentDescription = aDecoder.decodeObject(forKey: "assignmentDescription") as? String ?? ""
		courseName = aDecoder.decodeObject(forKey: "courseName") as? String ?? ""
		dueDate = aDecoder.decodeObject(forKey: "dueDate") as? Date ?? Date.distantPast
		links = (aDecoder.decodeObject(forKey: "links") as? [[String]])?.map { (title: $0[0], URL: $0[1]) } ?? []
		iD = aDecoder.decodeObject(forKey: "iD") as? String ?? ""
		super.init()
	}

	func encode(with aCoder: NSCoder) {
		aCoder.encode(title, forKey: "title")
		aCoder.encode(description, forKey: "assignmentDescription")
		aCoder.encode(courseName, forKey: "courseName")
		aCoder.encode(dueDate, forKey: "dueDate")
		aCoder.encode(links.map { [$0.title, $0.URL] }, forKey: "links")
		aCoder.encode(iD, forKey: "iD")
	}
}
