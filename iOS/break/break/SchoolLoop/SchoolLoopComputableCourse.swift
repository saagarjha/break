//
//  SchoolLoopComputableCourse.swift
//  break
//
//  Created by Saagar Jha on 12/16/16.
//  Copyright © 2016 Saagar Jha. All rights reserved.
//

import Foundation

/// Represents a single computable course, suitable for grade calculation.
public class SchoolLoopComputableCourse: SchoolLoopCourse {
	/// The computable categories associated with this computable course.
	public var computableCategories = [SchoolLoopComputableCategory]()
	
	/// The computable grades associated with this computable course.
	public var computableGrades = [SchoolLoopComputableGrade]()
	
	/// The computed score for this course.
	public var computedScore: Double {
		typealias SchoolLoopCheckedCategory = (weight: Double, score: Double)
		let categories = computableCategories.flatMap { (category: SchoolLoopComputableCategory) -> SchoolLoopCheckedCategory? in
			if let weight = category.computedWeight,
				let score = category.computedScore {
				return (weight, score)
			} else {
				return nil
			}
		}

		let totalWeight = categories.reduce(0) {
			return $0 + $1.weight
		}
		
		guard totalWeight > 0 else {
			return 1
		}
		return categories.reduce(0) { partialScore, category in
			return partialScore + category.score * category.weight / totalWeight
		}
	}
	
	/// The computed score difference for this computable course.
	public var computedScoreDifference: Double {
		guard let score = Double(percent: self.score) else { // Crashes compiler without self
			return 0
		}
		return computedScore - score / 100
	}

	/// The comparison result for this computable course.
	public var comparisonResult: ComparisonResult {
		guard let s = Double(percent: self.score) else { // Crashes compiler without self
			return .orderedSame
		}
		let score = String(format: "%.2f", s)
		let computedScore = String(format: "%.2f", self.computedScore * 100)
		if score < computedScore {
			return .orderedAscending
		} else if score > computedScore {
			return .orderedDescending
		} else {
			return .orderedSame
		}
	}

	/// Returns the computable category with the specified category name.
	///
	/// - Parameters:
	///   - categoryName: The category name to search for
	/// - Returns: The computable category with the specified name, if any
	func computableCategory(for categoryName: String) -> SchoolLoopComputableCategory? {
		for category in computableCategories {
			if category.name == categoryName {
				return category
			}
		}
		return nil
	}

	/// Returns the computable grades in the specified computable category.
	///
	/// - Parameters:
	///   - computableCategory: The computable category to retrieve
	///   grades for
	/// - Returns: The computable grades in the specified category
	func computableGrades(in computableCategory: SchoolLoopComputableCategory) -> [SchoolLoopComputableGrade] {
		return computableGrades.filter {
			return $0.computedCategoryName == computableCategory
		}
	}
}

extension Double {
	init?(percent: String) {
		guard percent.hasSuffix("%") else {
			self.init(percent)
			return
		}
		self.init(percent.substring(to: percent.index(before: percent.endIndex)))
	}
}
