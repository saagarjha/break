//
//  SchoolLoopComputableGrade.swift
//  break
//
//  Created by Saagar Jha on 12/16/16.
//  Copyright © 2016 Saagar Jha. All rights reserved.
//

import Foundation

/// Represents a single computable grade, suitable for grade calculation.
public class SchoolLoopComputableGrade: SchoolLoopGrade {
	/// The computable course associated with this computable grade.
	public weak var computableCourse: SchoolLoopComputableCourse?

	/// A Boolean that designates whether this computable grade is created by
	/// the user.
	public var isUserCreated = true


	/// The percent score for this computable grade.
	public override var percentScore: String {
		didSet {
			guard let maxPoints = computedMaxPoints,
				let percent = Double(percent: percentScore) else {
					return
			}
			score = "\(maxPoints * percent / 100)"
		}
	}


	/// The computable category for this computable grade.
	public var computedCategoryName: SchoolLoopComputableCategory? {
		get {
			return computableCourse?.computableCategory(for: categoryName)
		}
	}

	/// The computed percent score for this computable grade.
	public var computedPercentScore: Double? {
		get {
			guard let computedScore = computedScore,
				let computedMaxPoints = computedMaxPoints else {
					return Double(percent: percentScore).flatMap { $0 / 100 }
			}
			return computedScore / computedMaxPoints
		}
	}

	/// The computed score for this computable grade.
	public var computedScore: Double? {
		get {
			return Double(score)
		}
	}

	/// The computed max points for this computed grade.
	public var computedMaxPoints: Double? {
		get {
			return Double(maxPoints)
		}
	}
}
