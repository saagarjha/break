//
//  SchoolLoopError.swift
//  break
//
//  Created by Saagar Jha on 1/28/16.
//  Copyright © 2016 Saagar Jha. All rights reserved.
//

import Foundation

enum SchoolLoopError: Error {
    case noError
	case unknownError
    case doesNotExistError
	case authenticationError
	case networkError
	case parseError
}
