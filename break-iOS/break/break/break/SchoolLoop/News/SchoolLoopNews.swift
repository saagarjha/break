//
//  SchoolLoopNews.swift
//  break
//
//  Created by Saagar Jha on 1/31/16.
//  Copyright © 2016 Saagar Jha. All rights reserved.
//

import Foundation

@objc(SchoolLoopNews)
class SchoolLoopNews: NSObject, NSCoding {
	var title: String
	var authorName: String
	var createdDate: NSDate
	var newsDescription: String
	var links: [(title: String, URL: String)]
	var iD: String

	init(title: String, authorName: String, createdDate: String, newsDescription: String, links: [(title: String, URL: String)], iD: String) {
		self.title = title
		self.authorName = authorName
		self.createdDate = NSDate(timeIntervalSince1970: NSTimeInterval(createdDate)! / 1000)
		self.newsDescription = newsDescription
		self.links = links
		self.iD = iD
		super.init()
	}

	func setNewCreatedDate(createdDate: String) {
		self.createdDate = NSDate(timeIntervalSince1970: NSTimeInterval(createdDate)! / 1000)
	}

	required init?(coder aDecoder: NSCoder) {
		title = aDecoder.decodeObjectForKey("title") as? String ?? ""
		authorName = aDecoder.decodeObjectForKey("authorName") as? String ?? ""
		createdDate = aDecoder.decodeObjectForKey("createdDate") as? NSDate ?? NSDate.distantPast()
		newsDescription = aDecoder.decodeObjectForKey("newsDescription") as? String ?? ""
		links = aDecoder.decodeObjectForKey("links") as? [(title: String, URL: String)] ?? []
		iD = aDecoder.decodeObjectForKey("iD") as? String ?? ""
		super.init()
	}

	func encodeWithCoder(aCoder: NSCoder) {
		aCoder.encodeObject(title, forKey: "title")
		aCoder.encodeObject(authorName, forKey: "authorName")
		aCoder.encodeObject(createdDate, forKey: "createdDate")
		aCoder.encodeObject(newsDescription, forKey: "newsDescription")
		aCoder.encodeObject(links as? AnyObject, forKey: "links")
		aCoder.encodeObject(iD, forKey: "iD")
	}
}
