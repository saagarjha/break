//
//  SchoolLoopGrade.swift
//  break
//
//  Created by Saagar Jha on 1/19/16.
//  Copyright © 2016 Saagar Jha. All rights reserved.
//

import Foundation

class SchoolLoopGrade {
	var title: String
	var categoryName: String
	var percentScore: String
	var score: String
	var maxPoints: String

	init(title: String, categoryName: String, percentScore: String, score: String, maxPoints: String) {
		self.title = title
		self.categoryName = categoryName
		self.percentScore = percentScore
		self.score = score
		self.maxPoints = maxPoints
	}
}
