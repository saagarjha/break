//
//  SchoolLoopLockerDelegate.swift
//  break
//
//  Created by Saagar Jha on 2/25/16.
//  Copyright © 2016 Saagar Jha. All rights reserved.
//

import Foundation

protocol SchoolLoopLockerDelegate: class {
    func gotLocker(schoolLoop: SchoolLoop, error: SchoolLoopError?)
}