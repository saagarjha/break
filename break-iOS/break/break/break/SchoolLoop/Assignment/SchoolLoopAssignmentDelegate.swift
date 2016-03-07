//
//  SchoolLoopAssignmentDelegate.swift
//  break
//
//  Created by Saagar Jha on 1/20/16.
//  Copyright © 2016 Saagar Jha. All rights reserved.
//

import Foundation

protocol SchoolLoopAssignmentDelegate: class {
	func gotAssignments(schoolLoop: SchoolLoop, error: SchoolLoopError?)
}
