//
//  GradeViewController.swift
//  break
//
//  Created by Saagar Jha on 5/23/16.
//  Copyright © 2016 Saagar Jha. All rights reserved.
//

import UIKit

class GradeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

	let cellIdentifier = "gradeDetail"

	var periodID: String!
	var systemID: String!

	var schoolLoop: SchoolLoop!
	var grade: SchoolLoopGrade!

	@IBOutlet weak var gradeTableView: UITableView! {
		didSet {
			gradeTableView.sectionFooterHeight = UITableViewAutomaticDimension
			gradeTableView.estimatedSectionFooterHeight = 80
		}
	}
	var commentsView = UIView(frame: UIScreen.mainScreen().bounds)
	var commentsLabel = UILabel()

	override func viewDidLoad() {
		super.viewDidLoad()

		// Do any additional setup after loading the view.
		schoolLoop = SchoolLoop.sharedInstance
		grade = schoolLoop.courseForPeriodID(periodID)?.gradeForSystemID(systemID)
//		commentsView.backgroundColor = UIColor.whiteColor()
		commentsLabel.translatesAutoresizingMaskIntoConstraints = false
		commentsLabel.text = grade.comment
		commentsLabel.numberOfLines = 0
		commentsView.addSubview(commentsLabel)
		let constraints = NSLayoutConstraint.constraintsWithVisualFormat("|-[commentsLabel]-|", options: [], metrics: nil, views: ["commentsLabel": commentsLabel]) + NSLayoutConstraint.constraintsWithVisualFormat("V:|[commentsLabel]|", options: [], metrics: nil, views: ["commentsLabel": commentsLabel])
		NSLayoutConstraint.activateConstraints(constraints)
		commentsView.setNeedsLayout()
		commentsView.layoutIfNeeded()
		gradeTableView.beginUpdates()
		gradeTableView.endUpdates()
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}

	func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
		return commentsView
	}

	func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
		return commentsView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize).height
	}

	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 3
	}

	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) else {
			assertionFailure("Could not deque UITableViewCell")
			return tableView.dequeueReusableCellWithIdentifier(cellIdentifier)!
		}
		let dateFormatter = NSDateFormatter()
		dateFormatter.dateFormat = "M/dd"
		switch indexPath.row {
		case 0:
			cell.textLabel?.text = "Due Date"
			cell.detailTextLabel?.text = dateFormatter.stringFromDate(grade.dueDate)
		case 1:
			cell.textLabel?.text = "Changed Date"
			cell.detailTextLabel?.text = dateFormatter.stringFromDate(grade.changedDate)
		case 2:
			cell.textLabel?.text = "Comments:"
			cell.detailTextLabel?.text = ""
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
