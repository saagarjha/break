//
//  ProgressReportViewController.swift
//  break
//
//  Created by Saagar Jha on 1/19/16.
//  Copyright © 2016 Saagar Jha. All rights reserved.
//

import UIKit

class ProgressReportViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

	let cellIdentifier = "grade"

	var periodID: String!

	var schoolLoop: SchoolLoop!
	var grades: [SchoolLoopGrade] = []

	@IBOutlet weak var gradesTableView: UITableView! {
		didSet {
			gradesTableView.rowHeight = UITableViewAutomaticDimension
			gradesTableView.estimatedRowHeight = 80.0
		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		// Do any additional setup after loading the view.
		schoolLoop = SchoolLoop.sharedInstance
		schoolLoop.getGrades(periodID) { error in
			dispatch_async(dispatch_get_main_queue()) {
				if error == .NoError {
					guard let grades = self.schoolLoop.courseForPeriodID(self.periodID)?.grades else {
						assertionFailure("Could not get grades for periodID")
						return
					}
					self.grades = grades
					self.gradesTableView.reloadData()
				}
			}
		}
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}

	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return grades.count
	}

	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as? GradeTableViewCell else {
			assertionFailure("Could not deque GradeTableViewCell")
			return tableView.dequeueReusableCellWithIdentifier(cellIdentifier)!
		}
		cell.titleLabel.text = grades[indexPath.row].title
		cell.categoryNameLabel.text = grades[indexPath.row].categoryName
		cell.percentScoreLabel.text = grades[indexPath.row].percentScore
		cell.scoreLabel.text = "\(grades[indexPath.row].score)/\(grades[indexPath.row].maxPoints)"
		return cell
	}

	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		tableView.deselectRowAtIndexPath(indexPath, animated: true)
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
