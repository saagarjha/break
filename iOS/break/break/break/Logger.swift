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

	static let dateFormatter: DateFormatter = {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "M/d H:mm:ss.SSS"
		return dateFormatter
	}()

	class func log(_ string: String = "") {
		DispatchQueue.main.async {
			if !FileManager.default.fileExists(atPath: filePath) {
				FileManager.default.createFile(atPath: filePath, contents: nil, attributes: nil)
			}
			let file = FileHandle(forUpdatingAtPath: filePath)
			file?.seekToEndOfFile()
			print("\(Logger.dateFormatter.string(from: Date())): \(string)")
			file?.write("\(Logger.dateFormatter.string(from: Date())): \(string)\n".data(using: String.Encoding.utf8)!)
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
