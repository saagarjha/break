//
//  SchoolLoopLoginDelegate.swift
//  break
//
//  Created by Saagar Jha on 1/18/16.
//  Copyright © 2016 Saagar Jha. All rights reserved.
//

import Foundation

protocol SchoolLoopLoginDelegate: class {
    func loggedIn(schoolLoop: SchoolLoop, error: SchoolLoopError?)
}
