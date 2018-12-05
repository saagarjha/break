//
//  breakTests.swift
//  breakTests
//
//  Created by Saagar Jha on 2/4/16.
//  Copyright © 2016 Saagar Jha. All rights reserved.
//

import XCTest
@testable import `break`

class breakTests: XCTestCase {
	func testColorUniqueness() {
		let sampleSize = 0b1_0000_0000
		var colors = Set<UIColor>()
		let offset = CGFloat.random(in: 0..<1)
		for index in 0..<sampleSize {
			colors.insert(UIColor(index: index, offset: offset))
		}
		XCTAssert(colors.count == sampleSize)
	}
}
