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
	static var dateFormatter: DateFormatter = {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
		return dateFormatter
	}()

	var title: String
	var categoryName: String
	var percentScore: String
	var score: String
	var maxPoints: String
	var comment: String
	var systemID: String
	var dueDate: Date
	var changedDate: Date

	init(title: String, categoryName: String, percentScore: String, score: String, maxPoints: String, comment: String, systemID: String, dueDate: String, changedDate: String) {
		self.title = title ?! ""
		self.categoryName = categoryName ?! ""
		self.percentScore = percentScore ?! ""
		self.score = score ?! ""
		self.maxPoints = maxPoints ?! ""
		self.comment = comment ?! ""
		self.systemID = systemID ?! ""
		self.dueDate = SchoolLoopGrade.dateFormatter.date(from: dueDate) ?? Date.distantPast
		self.changedDate = SchoolLoopGrade.dateFormatter.date(from: changedDate) ?? Date.distantPast
		super.init()
	}

	convenience init(grade: SchoolLoopGrade) {
		self.init(title: grade.title, categoryName: grade.categoryName, percentScore: grade.percentScore, score: grade.score, maxPoints: grade.maxPoints, comment: grade.comment, systemID: grade.systemID, dueDate: SchoolLoopGrade.dateFormatter.string(from: grade.dueDate), changedDate: SchoolLoopGrade.dateFormatter.string(from: grade.dueDate))
	}

	required init?(coder aDecoder: NSCoder) {
		title = aDecoder.decodeObject(forKey: "title") as? String ?? ""
		categoryName = aDecoder.decodeObject(forKey: "categoryName") as? String ?? ""
		percentScore = aDecoder.decodeObject(forKey: "percentScore") as? String ?? ""
		score = aDecoder.decodeObject(forKey: "score") as? String ?? ""
		maxPoints = aDecoder.decodeObject(forKey: "maxPoints") as? String ?? ""
		comment = aDecoder.decodeObject(forKey: "comment") as? String ?? ""
		systemID = aDecoder.decodeObject(forKey: "systemID") as? String ?? ""
		dueDate = aDecoder.decodeObject(forKey: "dueDate") as? Date ?? Date.distantPast
		changedDate = aDecoder.decodeObject(forKey: "changedDate") as? Date ?? Date.distantPast
		super.init()
	}

	func encode(with aCoder: NSCoder) {
		aCoder.encode(title, forKey: "title")
		aCoder.encode(categoryName, forKey: "categoryName")
		aCoder.encode(percentScore, forKey: "percentScore")
		aCoder.encode(score, forKey: "score")
		aCoder.encode(maxPoints, forKey: "maxPoints")
		aCoder.encode(comment, forKey: "comment")
		aCoder.encode(systemID, forKey: "systemID")
		aCoder.encode(dueDate, forKey: "dueDate")
		aCoder.encode(changedDate, forKey: "changedDate")
	}
}
