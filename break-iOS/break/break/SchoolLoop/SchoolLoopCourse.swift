//
//  SchoolLoopCourse.swift
//  break
//
//  Created by Saagar Jha on 1/19/16.
//  Copyright © 2016 Saagar Jha. All rights reserved.
//

import Foundation

@objc(SchoolLoopCourse)
class SchoolLoopCourse: NSObject, NSCoding {
	var courseName: String
	var period: String
	var teacherName: String
	var grade: String
	var score: String
	var periodID: String
	var lastUpdated: NSDate = NSDate.distantPast()

	var cutoffs: [SchoolLoopCutoff] = []
	var categories: [SchoolLoopCategory] = []
	var grades: [SchoolLoopGrade] = []
	var trendScores: [SchoolLoopTrendScore] = []

	init(courseName: String, period: String, teacherName: String, grade: String, score: String, periodID: String) {
		self.courseName = courseName
		self.period = period
		self.teacherName = teacherName
		self.grade = grade
		self.score = score
		self.periodID = periodID
		super.init()
	}

	func setNewLastUpdated(lastUpdated: String) -> Bool {
		let dateFormatter = NSDateFormatter()
		dateFormatter.dateFormat = "M/d/yy h:mm a"
		dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
		let newLastUpdated = dateFormatter.dateFromString(lastUpdated) ?? NSDate.distantPast()
		let updated = self.lastUpdated.compare(newLastUpdated) == .OrderedAscending
		self.lastUpdated = newLastUpdated
		return updated
	}

	required init?(coder aDecoder: NSCoder) {
		courseName = aDecoder.decodeObjectForKey("courseName") as? String ?? ""
		period = aDecoder.decodeObjectForKey("period") as? String ?? ""
		teacherName = aDecoder.decodeObjectForKey("teacherName") as? String ?? ""
		grade = aDecoder.decodeObjectForKey("grade") as? String ?? ""
		score = aDecoder.decodeObjectForKey("score") as? String ?? ""
		periodID = aDecoder.decodeObjectForKey("periodID") as? String ?? ""
		lastUpdated = aDecoder.decodeObjectForKey("lastUpdated") as? NSDate ?? NSDate.distantPast()
		cutoffs = aDecoder.decodeObjectForKey("cutoffs") as? [SchoolLoopCutoff] ?? []
		categories = aDecoder.decodeObjectForKey("categories") as? [SchoolLoopCategory] ?? []
		grades = aDecoder.decodeObjectForKey("grades") as? [SchoolLoopGrade] ?? []
		trendScores = aDecoder.decodeObjectForKey("trendScores") as? [SchoolLoopTrendScore] ?? []
		super.init()
	}

	func encodeWithCoder(aCoder: NSCoder) {
		aCoder.encodeObject(courseName, forKey: "courseName")
		aCoder.encodeObject(period, forKey: "period")
		aCoder.encodeObject(teacherName, forKey: "teacherName")
		aCoder.encodeObject(grade, forKey: "grade")
		aCoder.encodeObject(score, forKey: "score")
		aCoder.encodeObject(periodID, forKey: "periodID")
		aCoder.encodeObject(lastUpdated, forKey: "lastUpdated")
		aCoder.encodeObject("cutoffs", forKey: "cutoffs")
		aCoder.encodeObject(categories, forKey: "categories")
		aCoder.encodeObject(grades, forKey: "grades")
		aCoder.encodeObject(trendScores, forKey: "trendScores")
	}

	func gradeForSystemID(systemID: String) -> SchoolLoopGrade? {
		for grade in grades {
			if grade.systemID == systemID {
				return grade
			}
		}
		return nil
	}
}
