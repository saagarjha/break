//
//  Logger.swift
//  break
//
//  Created by Saagar Jha on 3/25/16.
//  Copyright © 2016 Saagar Jha. All rights reserved.
//

import Foundation

class Logger {
	static let filePath = (NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as NSString).stringByAppendingPathComponent("log.txt")

	class func log(string: String) {
		if !NSFileManager.defaultManager().fileExistsAtPath(filePath) {
			NSFileManager.defaultManager().createFileAtPath(filePath, contents: nil, attributes: nil)
		}
		let formatter = NSDateFormatter()
		formatter.dateFormat = "M/d H:mm:ss.SSS"
		let file = NSFileHandle(forUpdatingAtPath: filePath)
		file?.seekToEndOfFile()
		file?.writeData("\(formatter.stringFromDate(NSDate())): \(string)\n".dataUsingEncoding(NSUTF8StringEncoding)!)
		file?.closeFile()
	}

	class func readLog() -> String {
		do {
			return try String(contentsOfFile: filePath, encoding: NSUTF8StringEncoding)
		} catch _ {
			return ""
		}
	}

	class func clearLog() {
		NSFileManager.defaultManager().createFileAtPath(filePath, contents: nil, attributes: nil)
	}
}