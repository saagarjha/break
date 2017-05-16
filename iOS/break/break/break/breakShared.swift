//
//  breakShared.swift
//  break
//
//  Created by Saagar Jha on 4/28/17.
//  Copyright © 2017 Saagar Jha. All rights reserved.
//

import UIKit

extension UIColor {
	static let `break` = #colorLiteral(red: 0.1019607843, green: 0.737254902, blue: 0.6117647059, alpha: 1)
	
	convenience init(string: String) {
		let hashValue = UInt(bitPattern: string.hashValue)
		let channelSize = UInt(MemoryLayout<Int>.size * 8 / 3)
		let mask = 1 << channelSize - 1
		let red = CGFloat(hashValue & mask) / CGFloat(mask + 1)
		let green = CGFloat(hashValue >> channelSize & mask) / CGFloat(mask + 1)
		let blue = CGFloat(hashValue >> (channelSize * 2) & mask) / CGFloat(mask + 1)
		self.init(red: red, green: green, blue: blue, alpha: 1)
	}
}

enum breakTabIndices: Int, CustomStringConvertible {
	case courses = 0
	case assignments
	case loopMail
	case news
	case locker
	
	var description: String {
		switch self {
		case .courses:
			return "Courses"
		case .assignments:
			return "Assignments"
		case .loopMail:
			return "LoopMail"
		case .news:
			return "News"
		case .locker:
			return "Locker"
		}
	}
}

extension UISearchResultsUpdating where Self: UIViewController {
	func addSearchBar(from searchController: UISearchController, to tableView: UITableView) {
		definesPresentationContext = true
		searchController.searchResultsUpdater = self
		searchController.dimsBackgroundDuringPresentation = false
		tableView.tableHeaderView = searchController.searchBar
		// Hide the search bar by default
		tableView.contentOffset.y = searchController.searchBar.frame.height
	}
}

enum breakConstants {
	static let loginStationaryAnimationDuration = 1.0
	static let loginMovableAnimationDuration = 0.5
	static let loginMovableAnimationDelay = 0.1
		
	static let webViewDefaultStyle = "<meta name=\"viewport\" content=\"initial-scale=1.0\" /><style type=\"text/css\">body{font: -apple-system-body;}</style>"
	
	static let tableViewCellVerticalPadding = 12
	
	static let discriminatorViewWidth: CGFloat = 4
}

enum breakShared {
	static func autoresizeTableViewCells(for tableView: UITableView) {
		tableView.rowHeight = UITableViewAutomaticDimension
		tableView.estimatedRowHeight = 80.0
	}
	
	static func addRefreshControl(_ refreshControl: UIRefreshControl, to tableView: UITableView) {
		if #available(iOS 10.0, *) {
			tableView.refreshControl = refreshControl
		} else {
			tableView.addSubview(refreshControl)
			tableView.backgroundView = UIView()
			tableView.backgroundView?.backgroundColor = .clear
		}
	}
	
	static func addRefreshControl(_ refreshControl: UIRefreshControl, to collectionView: UICollectionView) {
		if #available(iOS 10.0, *) {
			collectionView.refreshControl = refreshControl
		} else {
			collectionView.addSubview(refreshControl)
			collectionView.backgroundView = UIView()
			collectionView.backgroundView?.backgroundColor = .clear
		}
	}
}
