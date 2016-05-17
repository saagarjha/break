//
//  ProgressReportViewController.swift
//  break
//
//  Created by Saagar Jha on 1/19/16.
//  Copyright © 2016 Saagar Jha. All rights reserved.
//

import UIKit

class ProgressReportViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchControllerDelegate, UISearchResultsUpdating {

	let cellIdentifier = "grade"

	var periodID: String!

	var schoolLoop: SchoolLoop!
	var grades: [SchoolLoopGrade] = []
	var filteredGrades: [SchoolLoopGrade] = []

	@IBOutlet weak var gradesTableView: UITableView! {
		didSet {
			gradesTableView.rowHeight = UITableViewAutomaticDimension
			gradesTableView.estimatedRowHeight = 80.0
		}
	}
	let searchController = UISearchController(searchResultsController: nil)
    
    deinit {
        searchController.loadViewIfNeeded()
    }

	override func viewDidLoad() {
		super.viewDidLoad()

		// Do any additional setup after loading the view.
        definesPresentationContext = true
		searchController.searchResultsUpdater = self
		searchController.delegate = self
        searchController.dimsBackgroundDuringPresentation = false
		gradesTableView.tableHeaderView = searchController.searchBar
		schoolLoop = SchoolLoop.sharedInstance
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
		schoolLoop.getGrades(periodID) { error in
			dispatch_async(dispatch_get_main_queue()) {
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
				if error == .NoError {
					guard let grades = self.schoolLoop.courseForPeriodID(self.periodID)?.grades else {
						assertionFailure("Could not get grades for periodID")
						return
					}
					self.grades = grades
					self.updateSearchResultsForSearchController(self.searchController)
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
		return filteredGrades.count
	}

	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as? GradeTableViewCell else {
			assertionFailure("Could not deque GradeTableViewCell")
			return tableView.dequeueReusableCellWithIdentifier(cellIdentifier)!
		}
		let grade = filteredGrades[indexPath.row]
		cell.titleLabel.text = grade.title
		cell.categoryNameLabel.text = grade.categoryName
		cell.percentScoreLabel.text = grade.percentScore
		cell.scoreLabel.text = "\(grade.score)/\(grade.maxPoints)"
		return cell
	}

	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		tableView.deselectRowAtIndexPath(indexPath, animated: true)
	}

	func updateSearchResultsForSearchController(searchController: UISearchController) {
		let filter = searchController.searchBar.text?.lowercaseString ?? ""
		if filter != "" {
			filteredGrades.removeAll()
			filteredGrades = grades.filter { grade in
				return grade.title.lowercaseString.containsString(filter) || grade.categoryName.lowercaseString.containsString(filter)
			}
		} else {
			filteredGrades = grades
		}
		dispatch_async(dispatch_get_main_queue()) {
			self.gradesTableView.reloadData()
		}
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
