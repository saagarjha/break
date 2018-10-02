//
//  SchoolLoopCourse.swift
//  break
//
//  Created by Saagar Jha on 1/19/16.
//  Copyright © 2016 Saagar Jha. All rights reserved.
//

import Foundation

/// Represents a single course.
@objc(SchoolLoopCourse)
public class SchoolLoopCourse: NSObject, NSCoding {
	/// A shared date formatter for parsing the last updated date.
	private static let dateFormatter: DateFormatter = {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "M/d/yy h:mm a"
		dateFormatter.locale = Locale(identifier: "en_US_POSIX")
		return dateFormatter
	}()


	/// A factory instance variable for a computable course.
	/// - Remark: This should probably be a method.
	public var computableCourse: SchoolLoopComputableCourse {
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
		computableCourse.precision = precision
		return computableCourse
	}


	/// The name of this course.
	public var courseName: String

	/// The period for this course.
	public var period: String

	/// The name of the teacher for this course.
	public var teacherName: String

	/// The grade for this course.
	public var grade: String

	/// The score for this course.
	public var score: String

	/// The period ID of this course.
	public var periodID: String

	/// The last updated time for this course.
	public var lastUpdated: Date = Date.distantPast


	/// The cutoffs associated with this course.
	public var cutoffs = [SchoolLoopCutoff]()

	/// The categories associated with this course.
	public var categories = [SchoolLoopCategory]()

	/// The grades associated with this course.
	public var grades = [SchoolLoopGrade]()

	/// The trend scores associated with this course.
	public var trendScores = [SchoolLoopTrendScore]()

	/// The precision of the score for this course.
	public var precision: Int = 0


	/// This class supports secure coding.
	public static var supportsSecureCoding = true


	/// Create a new course with the specified values.
	///
	/// - Parameters:
	///   - courseName: The name of this course
	///   - period: The period for this course
	///   - teacherName: The name of the teacher for this course
	///   - grade: The grade for this course
	///   - score: The score for this course
	///   - periodID: The period ID for this course
	public init(courseName: String, period: String, teacherName: String, grade: String, score: String, periodID: String) {
		self.courseName = courseName ?! ""
		self.period = period ?! ""
		self.teacherName = teacherName ?! ""
		self.grade = grade ?! ""
		self.score = score ?! ""
		self.periodID = periodID ?! ""
		super.init()
	}

	/// Copy constructor.
	///
	/// - Parameter course: The course to copy
	convenience init(course: SchoolLoopCourse) {
		self.init(courseName: course.courseName, period: course.period, teacherName: course.teacherName, grade: course.grade, score: course.score, periodID: course.periodID)
		self.lastUpdated = course.lastUpdated
		self.cutoffs = course.cutoffs
		self.categories = course.categories
		self.grades = course.grades
		self.trendScores = course.trendScores
	}

	/// Sets a new updated value for this course and returns whether there was
	/// an update.
	///
	/// - Parameters:
	///   - lastUpdated: The new last updated value
	/// - Returns: Whether the course was updated
	func set(newLastUpdated lastUpdated: String) -> Bool {
		let newLastUpdated = SchoolLoopCourse.dateFormatter.date(from: lastUpdated) ?? Date.distantPast
		let updated = self.lastUpdated.compare(newLastUpdated) == .orderedAscending
		self.lastUpdated = newLastUpdated
		return updated
	}

	/// `NSCoding` initializer. You probably don't want to invoke this directly.
	public required init?(coder aDecoder: NSCoder) {
		courseName = aDecoder.decodeObject(of: NSString.self, forKey: "courseName") as String? ?? ""
		period = aDecoder.decodeObject(of: NSString.self, forKey: "period") as String? ?? ""
		teacherName = aDecoder.decodeObject(of: NSString.self, forKey: "teacherName") as String? ?? ""
		grade = aDecoder.decodeObject(of: NSString.self, forKey: "grade") as String? ?? ""
		score = aDecoder.decodeObject(of: NSString.self, forKey: "score") as String? ?? ""
		periodID = aDecoder.decodeObject(of: NSString.self, forKey: "periodID") as String? ?? ""
		lastUpdated = aDecoder.decodeObject(of: NSDate.self, forKey: "lastUpdated") as Date? ?? Date.distantPast
		cutoffs = aDecoder.decodeObject(of: [NSArray.self, SchoolLoopCutoff.self], forKey: "cutoffs") as? [SchoolLoopCutoff] ?? []
		categories = aDecoder.decodeObject(of: [NSArray.self, SchoolLoopCategory.self], forKey: "categories") as? [SchoolLoopCategory] ?? []
		grades = aDecoder.decodeObject(of: [NSArray.self, SchoolLoopGrade.self], forKey: "grades") as? [SchoolLoopGrade] ?? []
		trendScores = aDecoder.decodeObject(of: [NSArray.self, SchoolLoopTrendScore.self], forKey: "trendScores") as? [SchoolLoopTrendScore] ?? []
		super.init()
	}

	/// `NSCoding` encoding. You probably don't want to invoke this directly.
	public func encode(with aCoder: NSCoder) {
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

	public func set(newPrecision precision: String) {
		self.precision = Int(precision) ?? 0
	}


	/// Returns the grade with the specified system ID.
	///
	/// - Parameters:
	///   - systemID: The system ID of the grade to search for
	/// - Returns: The grade matching the specified system ID, if any
	public func grade(forSystemID systemID: String) -> SchoolLoopGrade? {
		return grades.first { $0.systemID == systemID }
	}
}
