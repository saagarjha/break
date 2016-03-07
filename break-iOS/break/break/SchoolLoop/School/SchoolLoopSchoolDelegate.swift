//
//  SchoolLoopSchoolDelegate.swift
//  break
//
//  Created by Saagar Jha on 1/28/16.
//  Copyright © 2016 Saagar Jha. All rights reserved.
//

import Foundation

protocol SchoolLoopSchoolDelegate: class {
	func gotSchools(schoolLoop: SchoolLoop, error: SchoolLoopError?)
}
