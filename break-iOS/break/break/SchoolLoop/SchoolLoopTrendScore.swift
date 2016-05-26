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
	var dayID: NSDate

	init(score: String, dayID: String) {
		self.score = score
		self.dayID = NSDate(timeIntervalSince1970: (NSTimeInterval(dayID) ?? 0) / 1000)
	}

	required init?(coder aDecoder: NSCoder) {
		score = aDecoder.decodeObjectForKey("score") as? String ?? ""
		dayID = aDecoder.decodeObjectForKey("dayID") as? NSDate ?? NSDate.distantPast()
	}

	func encodeWithCoder(aCoder: NSCoder) {
		aCoder.encodeObject(score, forKey: "score")
		aCoder.encodeObject(dayID, forKey: "dayID")
	}
}