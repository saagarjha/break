//
//  SchoolLoopTrendScore.swift
//  break
//
//  Created by Saagar Jha on 5/19/16.
//  Copyright © 2016 Saagar Jha. All rights reserved.
//

import Foundation

@objc(SchoolLoopTrendScore)
class SchoolLoopTrendScore: NSObject, NSCoding {
	var score: String
	var dayID: Date

	init(score: String, dayID: String) {
		self.score = score
		self.dayID = Date(timeIntervalSince1970: (TimeInterval(dayID) ?? 0) / 1000)
		super.init()
	}

	required init?(coder aDecoder: NSCoder) {
		score = aDecoder.decodeObject(forKey: "score") as? String ?? ""
		dayID = aDecoder.decodeObject(forKey: "dayID") as? Date ?? Date.distantPast
		super.init()
	}

	func encode(with aCoder: NSCoder) {
		aCoder.encode(score, forKey: "score")
		aCoder.encode(dayID, forKey: "dayID")
	}
}
