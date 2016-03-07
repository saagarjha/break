//
//  SchoolLoopSchool.swift
//  break
//
//  Created by Saagar Jha on 1/28/16.
//  Copyright © 2016 Saagar Jha. All rights reserved.
//

import Foundation

class SchoolLoopSchool {
	var name: String!
	var domainName: String!

	init(name: String, domainName: String) {
		self.name = name
		self.domainName = domainName
	}
}

extension SchoolLoopSchool: Comparable { }

func == (lhs: SchoolLoopSchool, rhs: SchoolLoopSchool) -> Bool {
	return lhs.name == rhs.name
}

func < (lhs: SchoolLoopSchool, rhs: SchoolLoopSchool) -> Bool {
	return lhs.name < rhs.name
}
