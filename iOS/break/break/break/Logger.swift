//
//  Logger.swift
//  break
//
//  Created by Saagar Jha on 3/25/16.
//  Copyright © 2016 Saagar Jha. All rights reserved.
//

import Foundation

class Logger {
	static let filePath = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent("log.txt")

	class func log(_ string: String = "") {
		DispatchQueue.main.async {
			if !FileManager.default.fileExists(atPath: filePath) {
				FileManager.default.createFile(atPath: filePath, contents: nil, attributes: nil)
			}
			let formatter = DateFormatter()
			formatter.dateFormat = "M/d H:mm:ss.SSS"
			let file = FileHandle(forUpdatingAtPath: filePath)
			file?.seekToEndOfFile()
//		#if arch(i386) || arch(x86_64)
			print("\(formatter.string(from: Date())): \(string)")
//		#else
			file?.write("\(formatter.string(from: Date())): \(string)\n".data(using: String.Encoding.utf8)!)
//		#endif
			file?.closeFile()
		}
	}

	class func readLog() -> String {
		return (try? String(contentsOfFile: filePath, encoding: String.Encoding.utf8)) ?? ""
	}

	class func clearLog() {
		DispatchQueue.main.async {
			FileManager.default.createFile(atPath: filePath, contents: nil, attributes: nil)
		}
	}
}
