//
//  SchoolLoopNewsDelegate.swift
//  break
//
//  Created by Saagar Jha on 1/31/16.
//  Copyright © 2016 Saagar Jha. All rights reserved.
//

import Foundation

protocol SchoolLoopNewsDelegate: class {
    func gotNews(schoolLoop: SchoolLoop, error: SchoolLoopError?)
}
