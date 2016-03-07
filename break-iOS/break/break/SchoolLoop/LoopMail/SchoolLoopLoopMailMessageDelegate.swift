//
//  SchoolLoopLoopMailMessageDelegate.swift
//  break
//
//  Created by Saagar Jha on 1/23/16.
//  Copyright © 2016 Saagar Jha. All rights reserved.
//

import Foundation

protocol SchoolLoopLoopMailMessageDelegate: class {
	func gotLoopMailMessage(schoolLoop: SchoolLoop, error: SchoolLoopError?)
}
