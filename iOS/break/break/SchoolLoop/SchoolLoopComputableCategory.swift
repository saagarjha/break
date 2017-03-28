//
//  SchoolLoopComputableCategory.swift
//  break
//
//  Created by Saagar Jha on 12/16/16.
//  Copyright © 2016 Saagar Jha. All rights reserved.
//

import Foundation

class SchoolLoopComputableCategory: SchoolLoopCategory {
	weak var computableCourse: SchoolLoopComputableCourse?
	var isUserCreated = true

	var computedScore: Double? {
		let (score, maxPoints) = computedTotals
		guard maxPoints != 0 else {
			return nil
		}
		return score / maxPoints
	}
	var computedWeight: Double? {
		if weight.hasSuffix("%"),
			let w = SchoolLoopComputableCourse.double(forPercent: weight) { // Workaround for SR-4082
			return w / 100
		} else {
			return Double(weight)
		}
	}
	var computedTotals: (Double, Double) {
		guard let grades = computableCourse?.computableGrades(in: self),
			!grades.isEmpty else {
				return (0, 0)
		}
		var score = 0.0
		var maxPoints = 0.0
		for grade in grades {
			if let computedScore = grade.computedScore,
				let computedMaxPoints = grade.computedMaxPoints {
				score += computedScore
				maxPoints += computedMaxPoints
			}
		}
		return (score, maxPoints)
	}
	var computedScoreDifference: Double? {
		guard let computedScore = computedScore,
			let score = Double(score) else {
			return 0
		}
		return computedScore - score
	}
	
	var comparisonResult: ComparisonResult {
		guard let s = Double(self.score),
			let cs = self.computedScore else { // Crashes compiler without self
				return .orderedSame
		}
		let score = String(format: "%.2f", s)
		let computedScore = String(format: "%.2f", cs)
		if score < computedScore {
			 return .orderedAscending
		} else if score > computedScore {
			return .orderedDescending
		} else {
			return .orderedSame
		}
	}
}
