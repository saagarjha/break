//
//  ViewMode.swift
//  break
//
//  Created by Saagar Jha on 2/19/17.
//  Copyright © 2017 Saagar Jha. All rights reserved.
//

import Foundation

enum ViewMode: Int, CustomStringConvertible {
	case calculated = 0
	case original
	case weights
	case totals
	case _count

	var description: String {
		switch self {
		case .calculated:
			return "Calculated"
		case .original:
			return "Original"
		case .weights:
			return "Weights"
		case .totals:
			return "Totals"
		default:
			assertionFailure("ViewMode is unrepresentable")
			return ""
		}
	}
}
