//
//  SchoolLoopComputableGrade.swift
//  break
//
//  Created by Saagar Jha on 12/16/16.
//  Copyright © 2016 Saagar Jha. All rights reserved.
//

import Foundation

class SchoolLoopComputableGrade: SchoolLoopGrade {
	weak var computableCourse: SchoolLoopComputableCourse?
	var isUserCreated = true

	override var percentScore: String {
		didSet {
			guard let maxPoints = computedMaxPoints,
				let percent = SchoolLoopComputableCourse.double(forPercent: percentScore) else {
					return
			}
			score = "\(maxPoints * percent / 100)"
		}
	}

	var computedCategoryName: SchoolLoopComputableCategory? {
		get {
			return computableCourse?.computableCategory(for: categoryName)
		}
	}
	var computedPercentScore: Double? {
		get {
			guard let computedScore = computedScore,
				let computedMaxPoints = computedMaxPoints else {
					return nil
			}
			return computedScore / computedMaxPoints
		}
	}
	var computedScore: Double? {
		get {
			return Double(score)
		}
	}
	var computedMaxPoints: Double? {
		get {
			return Double(maxPoints)
		}
	}
}
