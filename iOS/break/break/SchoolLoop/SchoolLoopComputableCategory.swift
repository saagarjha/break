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
		get {
			let (score, maxPoints) = computedTotals
			guard maxPoints != 0 else {
				return nil
			}
			return score / maxPoints
		}
	}
	var computedWeight: Double? {
		get {
			if weight.hasSuffix("%"),
				let w = SchoolLoopComputableCourse.double(forPercent: weight) { // Workaround for SR-4082
					return w / 100
			} else {
					return Double(weight)
			}
		}
	}
	var computedTotals: (Double, Double) {
		get {
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
	}
}
