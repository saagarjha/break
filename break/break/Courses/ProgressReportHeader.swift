//
//  ProgressReportHeader.swift
//  break
//
//  Created by Saagar Jha on 2/7/17.
//  Copyright © 2017 Saagar Jha. All rights reserved.
//

import UIKit

class ProgressReportHeader: NSObject, UITableViewDataSource, UITableViewDelegate {

	static let cellIdentifier = "progressReportHeader"

	var title: (title: String, subtitle: String, comparisonResult: ComparisonResult)?
	var headers = [(title: String, subtitle: String, comparisonResult: ComparisonResult)]() {
		didSet {
			headerTableView.reloadData()
		}
	}

	let headerTableView: UITableView

	override init() {
		headerTableView = UITableView()
		headerTableView.isScrollEnabled = false
		headerTableView.separatorStyle = .none
		headerTableView.allowsSelection = false
		let seperatorView = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 0, height: 1 / UIScreen.main.scale)))
		seperatorView.backgroundColor = headerTableView.separatorColor
		headerTableView.tableFooterView = seperatorView

		super.init()
		headerTableView.dataSource = self
		headerTableView.delegate = self
		headerTableView.register(ProgressReportHeaderTableViewCell.self, forCellReuseIdentifier: ProgressReportHeader.cellIdentifier)
	}

	func numberOfSections(in tableView: UITableView) -> Int {
		return 2
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch section {
		case 0:
			return title != nil ? 1 : 0
		case 1:
			return headers.count
		default:
			assertionFailure("Invalid section for headerTableView")
			return 0
		}
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: ProgressReportHeader.cellIdentifier, for: indexPath) as? ProgressReportHeaderTableViewCell else {
			assertionFailure("Could not deque ProgressReportHeaderTableViewCell")
			return tableView.dequeueReusableCell(withIdentifier: ProgressReportHeader.cellIdentifier, for: indexPath)
		}
		cell.subtitleLabel.textColor = cell.titleLabel.textColor
		switch indexPath.section {
		case 0:
			cell.isBold = true
			cell.discriminatorView.backgroundColor = .clear
			cell.titleLabel.text = title?.title ?? ""
			cell.subtitleLabel.text = title?.subtitle ?? ""
			if let title = title {
				switch title.comparisonResult {
				case .orderedDescending:
					cell.subtitleLabel.textColor = .red
				case .orderedSame:
					cell.subtitleLabel.textColor = .black
				case .orderedAscending:
					cell.subtitleLabel.textColor = .green
				}
			}
		case 1:
			let header = headers[indexPath.row]
			cell.discriminatorView.backgroundColor = UIColor(index: indexPath.row, offset: .categoryOffset)
			cell.titleLabel.text = header.title
			cell.subtitleLabel.text = header.subtitle
			switch header.comparisonResult {
			case .orderedDescending:
				cell.subtitleLabel.textColor = .red
			case .orderedSame:
				cell.subtitleLabel.textColor = .black
			case .orderedAscending:
				cell.subtitleLabel.textColor = .green
			}
		default:
			assertionFailure("Invalid section for headerTableView")
		}
		return cell
	}
}
