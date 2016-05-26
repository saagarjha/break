//
//  SchoolLoopGrade.swift
//  break
//
//  Created by Saagar Jha on 1/19/16.
//  Copyright © 2016 Saagar Jha. All rights reserved.
//

import Foundation

@objc(SchoolLoopGrade)
class SchoolLoopGrade: NSObject, NSCoding {
	var title: String
	var categoryName: String
	var percentScore: String
	var score: String
	var maxPoints: String
	var comment: String
	var systemID: String
	var dueDate: NSDate
	var changedDate: NSDate

	init(title: String, categoryName: String, percentScore: String, score: String, maxPoints: String, comment: String, systemID: String, dueDate: String, changedDate: String) {
		self.title = title
		self.categoryName = categoryName
		self.percentScore = percentScore
		self.score = score
		self.maxPoints = maxPoints
		self.comment = comment
		self.systemID = systemID
		let dateFormatter = NSDateFormatter()
		dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
		self.dueDate = dateFormatter.dateFromString(dueDate) ?? NSDate.distantPast()
		self.changedDate = dateFormatter.dateFromString(changedDate) ?? NSDate.distantPast()
		super.init()
	}

	required init?(coder aDecoder: NSCoder) {
		title = aDecoder.decodeObjectForKey("title") as? String ?? ""
		categoryName = aDecoder.decodeObjectForKey("categoryName") as? String ?? ""
		percentScore = aDecoder.decodeObjectForKey("percentScore") as? String ?? ""
		score = aDecoder.decodeObjectForKey("score") as? String ?? ""
		maxPoints = aDecoder.decodeObjectForKey("maxPoints") as? String ?? ""
		comment = aDecoder.decodeObjectForKey("comment") as? String ?? ""
		systemID = aDecoder.decodeObjectForKey("systemID") as? String ?? ""
		dueDate = aDecoder.decodeObjectForKey("dueDate") as? NSDate ?? NSDate.distantPast()
		changedDate = aDecoder.decodeObjectForKey("changedDate") as? NSDate ?? NSDate.distantPast()
	}

	func encodeWithCoder(aCoder: NSCoder) {
		aCoder.encodeObject(title, forKey: "title")
		aCoder.encodeObject(categoryName, forKey: "categoryName")
		aCoder.encodeObject(percentScore, forKey: "percentScore")
		aCoder.encodeObject(score, forKey: "score")
		aCoder.encodeObject(maxPoints, forKey: "maxPoints")
		aCoder.encodeObject(comment, forKey: "comment")
		aCoder.encodeObject(systemID, forKey: "systemID")
		aCoder.encodeObject(dueDate, forKey: "dueDate")
		aCoder.encodeObject(changedDate, forKey: "changedDate")
	}
}
