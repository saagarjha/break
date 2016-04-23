//
//  SchoolLoopGrade.swift
//  break
//
//  Created by Saagar Jha on 1/19/16.
//  Copyright © 2016 Saagar Jha. All rights reserved.
//

import Foundation

class SchoolLoopGrade: NSObject, NSCoding {
	var title: String
	var categoryName: String
	var percentScore: String
	var score: String
	var maxPoints: String

	init(title: String, categoryName: String, percentScore: String, score: String, maxPoints: String) {
		self.title = title
		self.categoryName = categoryName
		self.percentScore = percentScore
		self.score = score
		self.maxPoints = maxPoints
		super.init()
	}

	required init?(coder aDecoder: NSCoder) {
		title = aDecoder.decodeObjectForKey("title") as? String ?? ""
		categoryName = aDecoder.decodeObjectForKey("categoryName") as? String ?? ""
		percentScore = aDecoder.decodeObjectForKey("percentScore") as? String ?? ""
		score = aDecoder.decodeObjectForKey("score") as? String ?? ""
		maxPoints = aDecoder.decodeObjectForKey("maxPoints") as? String ?? ""
	}

	func encodeWithCoder(aCoder: NSCoder) {
		aCoder.encodeObject(title, forKey: "title")
		aCoder.encodeObject(categoryName, forKey: "categoryName")
		aCoder.encodeObject(percentScore, forKey: "percentScore")
		aCoder.encodeObject(score, forKey: "score")
		aCoder.encodeObject(maxPoints, forKey: "maxPoints")
	}
}
