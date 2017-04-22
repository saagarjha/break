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
	static let dateFormatter: DateFormatter = {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "M/d/yy h:mm a"
		dateFormatter.locale = Locale(identifier: "en_US_POSIX")
		return dateFormatter
	}()

	var computableCourse: SchoolLoopComputableCourse {
		get {
			let computableCourse = SchoolLoopComputableCourse(course: self)
			computableCourse.computableCategories = self.categories.map {
				let category = SchoolLoopComputableCategory(category: $0)
				category.isUserCreated = false
				category.computableCourse = computableCourse
				return category
			}
			computableCourse.computableGrades = self.grades.map {
				let grade = SchoolLoopComputableGrade(grade: $0)
				grade.isUserCreated = false
				grade.computableCourse = computableCourse
				return grade
			}
			return computableCourse
		}
	}

	var courseName: String
	var period: String
	var teacherName: String
	var grade: String
	var score: String
	var periodID: String
	var lastUpdated: Date = Date.distantPast

	var cutoffs = [SchoolLoopCutoff]()
	var categories = [SchoolLoopCategory]()
	var grades = [SchoolLoopGrade]()
	var trendScores = [SchoolLoopTrendScore]()

	init(courseName: String, period: String, teacherName: String, grade: String, score: String, periodID: String) {
		self.courseName = courseName ?! ""
		self.period = period ?! ""
		self.teacherName = teacherName ?! ""
		self.grade = grade ?! ""
		self.score = score ?! ""
		self.periodID = periodID ?! ""
		super.init()
	}

	convenience init(course: SchoolLoopCourse) {
		self.init(courseName: course.courseName, period: course.period, teacherName: course.teacherName, grade: course.grade, score: course.score, periodID: course.periodID)
		self.lastUpdated = course.lastUpdated
		self.cutoffs = course.cutoffs
		self.categories = course.categories
		self.grades = course.grades
		self.trendScores = course.trendScores
	}

	func set(newLastUpdated lastUpdated: String) -> Bool {
		let newLastUpdated = SchoolLoopCourse.dateFormatter.date(from: lastUpdated) ?? Date.distantPast
		let updated = self.lastUpdated.compare(newLastUpdated) == .orderedAscending
		self.lastUpdated = newLastUpdated
		return updated
	}

	required init?(coder aDecoder: NSCoder) {
		courseName = aDecoder.decodeObject(forKey: "courseName") as? String ?? ""
		period = aDecoder.decodeObject(forKey: "period") as? String ?? ""
		teacherName = aDecoder.decodeObject(forKey: "teacherName") as? String ?? ""
		grade = aDecoder.decodeObject(forKey: "grade") as? String ?? ""
		score = aDecoder.decodeObject(forKey: "score") as? String ?? ""
		periodID = aDecoder.decodeObject(forKey: "periodID") as? String ?? ""
		lastUpdated = aDecoder.decodeObject(forKey: "lastUpdated") as? Date ?? Date.distantPast
		cutoffs = aDecoder.decodeObject(forKey: "cutoffs") as? [SchoolLoopCutoff] ?? []
		categories = aDecoder.decodeObject(forKey: "categories") as? [SchoolLoopCategory] ?? []
		grades = aDecoder.decodeObject(forKey: "grades") as? [SchoolLoopGrade] ?? []
		trendScores = aDecoder.decodeObject(forKey: "trendScores") as? [SchoolLoopTrendScore] ?? []
		super.init()
	}

	func encode(with aCoder: NSCoder) {
		aCoder.encode(courseName, forKey: "courseName")
		aCoder.encode(period, forKey: "period")
		aCoder.encode(teacherName, forKey: "teacherName")
		aCoder.encode(grade, forKey: "grade")
		aCoder.encode(score, forKey: "score")
		aCoder.encode(periodID, forKey: "periodID")
		aCoder.encode(lastUpdated, forKey: "lastUpdated")
		aCoder.encode(cutoffs, forKey: "cutoffs")
		aCoder.encode(categories, forKey: "categories")
		aCoder.encode(grades, forKey: "grades")
		aCoder.encode(trendScores, forKey: "trendScores")
	}

	func grade(forSystemID systemID: String) -> SchoolLoopGrade? {
		for grade in grades {
			if grade.systemID == systemID {
				return grade
			}
		}
		return nil
	}
}
