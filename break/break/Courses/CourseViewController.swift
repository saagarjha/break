//
//  CourseViewController.swift
//  break
//
//  Created by Saagar Jha on 5/23/16.
//  Copyright © 2016 Saagar Jha. All rights reserved.
//

import UIKit

class CourseViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

	static let cellIdentifier = "courseDetail"

	var course: SchoolLoopComputableCourse!

	@IBOutlet weak var trendScore: TrendScore!
	@IBOutlet weak var courseTableView: UITableView! {
		didSet {
			breakShared.autoresizeTableViewCells(for: courseTableView)
			courseTableView.register(CourseDetailTableViewCell.self, forCellReuseIdentifier: CourseViewController.cellIdentifier)
		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		// Do any additional setup after loading the view.
		navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addCategory))
	}

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		trendScore.layoutMargins.left = courseTableView.layoutMargins.left
		trendScore.layoutMargins.right = courseTableView.layoutMargins.right
		trendScore.trendScores = course.trendScores
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	@objc func addCategory(_ sender: Any) {
		let category = SchoolLoopComputableCategory(name: "Category", score: "", weight: "0")
		category.computableCourse = course
		course.computableCategories.insert(category, at: 0)
		courseTableView.reloadData()
	}

	func numberOfSections(in tableView: UITableView) -> Int {
		return 3
	}

	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		switch section {
		case 0:
			return "General"
		case 1:
			return "Categories"
		case 2:
			return "Grading Scale Cutoffs"
		default:
			return nil
		}
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch section {
		case 0:
			return 1
		case 1:
			return course.computableCategories.count
		case 2:
			return course.cutoffs.count
		default:
			assertionFailure("Invalid section for courseTableView")
			return 0
		}
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: CourseViewController.cellIdentifier, for: indexPath) as? CourseDetailTableViewCell else {
			assertionFailure("")
			return tableView.dequeueReusableCell(withIdentifier: CourseViewController.cellIdentifier, for: indexPath)
		}
		switch indexPath.section {
		case 0:
			cell.discriminatorView.backgroundColor = .clear
			cell.titleLabel.text = "Last Updated"
			let dateFormatter = DateFormatter()
			dateFormatter.dateStyle = .short
			dateFormatter.timeStyle = .short
			cell.subtitleLabel.text = dateFormatter.string(from: course.lastUpdated)
		case 1:
			let category = course.computableCategories[indexPath.row]
			cell.courseViewController = self
			cell.indexPath = indexPath
			cell.isTappable = true
			cell.discriminatorView.backgroundColor = UIColor(index: indexPath.row, offset: .categoryOffset)
			cell.titleLabel.text = category.name
			if let weightValue = category.computedWeight {
				cell.subtitleLabel.text = String(format: "%.2f%%", weightValue * 100)
			} else {
				cell.subtitleLabel.text = course.categories[indexPath.row].weight
			}
		case 2:
			cell.discriminatorView.backgroundColor = .clear
			cell.titleLabel.text = "\(course.cutoffs[indexPath.row].Start)%"
			cell.subtitleLabel.text = course.cutoffs[indexPath.row].Name
		default:
			break
		}
		return cell
	}

	func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		return indexPath.section == 1
	}

	func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
		course.computableCategories.remove(at: indexPath.row)
		tableView.deleteRows(at: [indexPath], with: .fade)
	}

	func changedTitle(to title: String, for indexPath: IndexPath) {
		let category = course.computableCategories[indexPath.row]
		category.name = title
		courseTableView.reloadData()
	}

	func changedSubtitle(to subtitle: String, for indexPath: IndexPath) {
		let category = course.computableCategories[indexPath.row]
		if !subtitle.hasSuffix("%") {
			category.weight = subtitle.appending("%")
		} else {
			category.weight = subtitle
		}
		courseTableView.reloadData()
	}

	/*
	 // MARK: - Navigation

	 // In a storyboard-based application, you will often want to do a little preparation before navigation
	 override func prepareForSegue(segue: UIStoryboardSegue, sender: Any?) {
	 // Get the new view controller using segue.destinationViewController.
	 // Pass the selected object to the new view controller.
	 }
	 */

}
