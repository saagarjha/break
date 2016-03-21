//
//  SchoolLoopNews.swift
//  break
//
//  Created by Saagar Jha on 1/31/16.
//  Copyright © 2016 Saagar Jha. All rights reserved.
//

import Foundation

class SchoolLoopNews {
	var title: String
	var authorName: String
	var createdDate: NSDate
	var description: String
	var links: [(title: String, URL: String)]
	var iD: String

	init(title: String, authorName: String, createdDate: String, description: String, links: [(title: String, URL: String)], iD: String) {
		self.title = title
		self.authorName = authorName
		self.createdDate = NSDate(timeIntervalSince1970: NSTimeInterval(createdDate)! / 1000)
		self.description = description
		self.links = links
		self.iD = iD
	}

	func setCreatedDate(createdDate: String) {
		self.createdDate = NSDate(timeIntervalSince1970: NSTimeInterval(createdDate)! / 1000)
	}
}
