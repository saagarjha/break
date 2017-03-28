//
//  SchoolLoopComputableCourse.swift
//  break
//
//  Created by Saagar Jha on 12/16/16.
//  Copyright © 2016 Saagar Jha. All rights reserved.
//

import Foundation

class SchoolLoopComputableCourse: SchoolLoopCourse {
	var computedScore: Double {
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

		var score = 0.0
		for category in categories {
			score += category.score * category.weight / totalWeight
		}
		return score
	}
	var computableCategories: [SchoolLoopComputableCategory] = []
	var computableGrades: [SchoolLoopComputableGrade] = []
	var computedScoreDifference: Double {
		guard let score = SchoolLoopComputableCourse.double(forPercent: self.score) else { // Crashes compiler without self
			return 0
		}
		return computedScore - score / 100
	}

	var comparisonResult: ComparisonResult {
		guard let s = SchoolLoopComputableCourse.double(forPercent: self.score) else { // Crashes compiler without self
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

	func computableCategory(for categoryName: String) -> SchoolLoopComputableCategory? {
		for category in computableCategories {
			if category.name == categoryName {
				return category
			}
		}
		return nil
	}

	func computableGrades(in computableCategory: SchoolLoopComputableCategory) -> [SchoolLoopComputableGrade] {
		return computableGrades.filter {
			return $0.computedCategoryName == computableCategory
		}
	}

	class func double(forPercent percent: String) -> Double? {
		guard percent.hasSuffix("%") else {
			return Double(percent)
		}
		return Double(percent.substring(to: percent.index(before: percent.endIndex)))
	}
}
