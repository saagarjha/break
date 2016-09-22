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
	var createdDate: Date
	var newsDescription: String
	var links: [(title: String, URL: String)]
	var iD: String

	init(title: String, authorName: String, createdDate: String, newsDescription: String, links: [(title: String, URL: String)], iD: String) {
		self.title = title
		self.authorName = authorName
		self.createdDate = Date(timeIntervalSince1970: TimeInterval(createdDate)! / 1000)
		self.newsDescription = newsDescription
		self.links = links
		self.iD = iD
		super.init()
	}

	func set(newCreatedDate createdDate: String) {
		self.createdDate = Date(timeIntervalSince1970: TimeInterval(createdDate)! / 1000)
	}

	required init?(coder aDecoder: NSCoder) {
		title = aDecoder.decodeObject(forKey: "title") as? String ?? ""
		authorName = aDecoder.decodeObject(forKey: "authorName") as? String ?? ""
		createdDate = aDecoder.decodeObject(forKey: "createdDate") as? Date ?? Date.distantPast
		newsDescription = aDecoder.decodeObject(forKey: "newsDescription") as? String ?? ""
		links = aDecoder.decodeObject(forKey: "links") as? [(title: String, URL: String)] ?? []
		iD = aDecoder.decodeObject(forKey: "iD") as? String ?? ""
		super.init()
	}

	func encode(with aCoder: NSCoder) {
		aCoder.encode(title, forKey: "title")
		aCoder.encode(authorName, forKey: "authorName")
		aCoder.encode(createdDate, forKey: "createdDate")
		aCoder.encode(newsDescription, forKey: "newsDescription")
		aCoder.encode(links, forKey: "links")
		aCoder.encode(iD, forKey: "iD")
	}
}
