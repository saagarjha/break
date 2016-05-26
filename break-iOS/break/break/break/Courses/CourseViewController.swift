//
//  CourseViewController.swift
//  break
//
//  Created by Saagar Jha on 5/23/16.
//  Copyright © 2016 Saagar Jha. All rights reserved.
//

import UIKit

class CourseViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

	let cellIdentifier = "courseDetail"

	var periodID: String!

	var schoolLoop: SchoolLoop!
	var course: SchoolLoopCourse!

	@IBOutlet weak var trendScore: TrendScore!
	@IBOutlet weak var courseTableView: UITableView!

	override func viewDidLoad() {
		super.viewDidLoad()

		// Do any additional setup after loading the view.
		schoolLoop = SchoolLoop.sharedInstance
		course = schoolLoop.courseForPeriodID(periodID)
	}

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		trendScore.trendScores = course.trendScores
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 3
	}

	func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
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

	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch section {
		case 0:
			return 1
		case 1:
			return course.categories.count
		case 2:
			return course.cutoffs.count
		default:
			return 0
		}
	}

	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) else {
			assertionFailure("Could not deque UITableViewCell")
			return tableView.dequeueReusableCellWithIdentifier(cellIdentifier)!
		}
		switch indexPath.section {
		case 0:
			cell.textLabel?.text = "Last Updated"
			let dateFormatter = NSDateFormatter()
			dateFormatter.dateStyle = .ShortStyle
			dateFormatter.timeStyle = .ShortStyle
			cell.detailTextLabel?.text = dateFormatter.stringFromDate(course.lastUpdated)
		case 1:
			cell.textLabel?.text = course.categories[indexPath.row].name
			if let weightValue = Double(course.categories[indexPath.row].weight) {
				cell.detailTextLabel?.text = String(format: "%.2f%%", weightValue * 100)
			} else {
				cell.detailTextLabel?.text = course.categories[indexPath.row].weight
			}
		case 2:
			cell.textLabel?.text = "\(course.cutoffs[indexPath.row].Start)%"
			cell.detailTextLabel?.text = course.cutoffs[indexPath.row].Name
		default:
			break
		}
		return cell
	}

	/*
	 // MARK: - Navigation

	 // In a storyboard-based application, you will often want to do a little preparation before navigation
	 override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
	 // Get the new view controller using segue.destinationViewController.
	 // Pass the selected object to the new view controller.
	 }
	 */

}
