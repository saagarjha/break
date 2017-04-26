//
//  SchoolLoopLockerItemType.swift
//  break
//
//  Created by Saagar Jha on 2/25/16.
//  Copyright © 2016 Saagar Jha. All rights reserved.
//

/// A enumeration of recognized file types.
///
/// - directory: A directory.
/// - pdf: A .pdf file.
/// - txt: A .txt file.
/// - doc: A .doc or .docx file.
/// - xls: A .xls or .xlsx file.
/// - ppt: A .ppt or .pptx file.
/// - pages: A .pages file.
/// - numbers: A .numbers file.
/// - key: A .key file.
/// - unknown: An unknown file.
public enum SchoolLoopLockerItemType {
	case directory
	case pdf
	case txt
	case doc
	case xls
	case ppt
	case pages
	case numbers
	case key
	case unknown

	/// Create a locker item type from the specified filename's extension.
	///
	/// - Parameters:
	///   - filename: The filename to create the locker item type from
	init(filename: String) {
		switch filename {
		case _ where filename.hasSuffix(".pdf"):
			self = .pdf
		case _ where filename.hasSuffix(".txt"):
			self = .txt
		case _ where filename.hasSuffix(".doc") || filename.hasSuffix(".docx"):
			self = .doc
		case _ where filename.hasSuffix(".xls") || filename.hasSuffix(".xlsx"):
			self = .xls
		case _ where filename.hasSuffix(".ppt") || filename.hasSuffix(".pptx"):
			self = .ppt
		case _ where filename.hasSuffix("pages"):
			self = .pages
		case _ where filename.hasSuffix(".numbers"):
			self = .numbers
		case _ where filename.hasSuffix(".key"):
			self = .key
		default:
			self = .unknown
		}
	}
}
