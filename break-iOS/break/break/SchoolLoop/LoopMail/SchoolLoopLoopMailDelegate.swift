//
//  SchoolLoopLoopMailDelegate.swift
//  break
//
//  Created by Saagar Jha on 1/23/16.
//  Copyright © 2016 Saagar Jha. All rights reserved.
//

import Foundation

protocol SchoolLoopLoopMailDelegate: class {
	func gotLoopMail(schoolLoop: SchoolLoop, error: SchoolLoopError?)
}
