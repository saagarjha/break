//
//  SchoolLoopError.swift
//  break
//
//  Created by Saagar Jha on 1/28/16.
//  Copyright © 2016 Saagar Jha. All rights reserved.
//

import Foundation

enum SchoolLoopError: ErrorType {
    case NoError
	case UnknownError
    case DoesNotExistError
	case AuthenticationError
	case NetworkError
	case ParseError
}
