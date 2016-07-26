//
//  CoursesViewController.swift
//  break
//
//  Created by Saagar Jha on 1/19/16.
//  Copyright © 2016 Saagar Jha. All rights reserved.
//

import UIKit

class CoursesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchControllerDelegate, UISearchResultsUpdating, UIViewControllerPreviewingDelegate {

	let cellIdentifier = "course"

	var schoolLoop: SchoolLoop!
	var courses: [SchoolLoopCourse] = []
	var filteredCourses: [SchoolLoopCourse] = []

//	var destinationViewController: ProgressReportViewController!

	@IBOutlet weak var coursesTableView: UITableView! {
		didSet {
			coursesTableView.backgroundView = UIView()
			coursesTableView.backgroundView?.backgroundColor = .clear()
			coursesTableView.rowHeight = UITableViewAutomaticDimension
			coursesTableView.estimatedRowHeight = 80.0
			refreshControl.addTarget(self, action: #selector(CoursesViewController.refresh(_:)), for: .valueChanged)
			coursesTableView.addSubview(refreshControl)
		}
	}
	let refreshControl = UIRefreshControl()
	let searchController = UISearchController(searchResultsController: nil)

	deinit {
		searchController.loadViewIfNeeded()
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		courses = SchoolLoop.sharedInstance.courses
		updateSearchResults(for: searchController)
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		// Do any additional setup after loading the view.
		definesPresentationContext = true
		searchController.searchResultsUpdater = self
		searchController.delegate = self
		searchController.dimsBackgroundDuringPresentation = false
		coursesTableView.tableHeaderView = searchController.searchBar
		schoolLoop = SchoolLoop.sharedInstance
		if traitCollection.forceTouchCapability == .available {
			registerForPreviewing(with: self, sourceView: view)
		}
		refresh(self)
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	func refresh(_ sender: AnyObject) {
		UIApplication.shared().isNetworkActivityIndicatorVisible = true
		schoolLoop.getCourses { (_, error) in
			DispatchQueue.main.async {
				UIApplication.shared().isNetworkActivityIndicatorVisible = false
				if error == .noError {
					self.courses = self.schoolLoop.courses
					self.updateSearchResults(for: self.searchController)
				}
				self.refreshControl.perform(#selector(UIRefreshControl.endRefreshing), with: nil, afterDelay: 0)
			}
		}

	}

	@IBAction func openSettings(_ sender: AnyObject) {
		let viewController = UIStoryboard(name: "Settings", bundle: nil).instantiateViewController(withIdentifier: "settings")
		navigationController?.present(viewController, animated: true, completion: nil)
	}

	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return filteredCourses.count
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? CourseTableViewCell else {
			assertionFailure("Could not deque CourseTableViewCell")
			return tableView.dequeueReusableCell(withIdentifier: cellIdentifier)!
		}
		let course = filteredCourses[indexPath.row]
		cell.periodLabel.text = course.period
		cell.courseNameLabel.text = course.courseName
		cell.teacherNameLabel.text = course.teacherName
		cell.gradeLabel.text = course.grade
		cell.scoreLabel.text = course.score
		return cell
	}

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
	}

	func willDismissSearchController(_ searchController: UISearchController) {
		updateSearchResults(for: searchController)
	}

	func updateSearchResults(for searchController: UISearchController) {
		let filter = searchController.searchBar.text?.lowercased() ?? ""
		if filter != "" {
			filteredCourses.removeAll()
			filteredCourses = courses.filter { course in
				return course.courseName.lowercased().contains(filter) || course.teacherName.lowercased().contains(filter)
			}
		} else {
			filteredCourses = courses
		}
		DispatchQueue.main.async {
			self.coursesTableView.reloadData()
		}
	}

	// MARK: - Navigation

	func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
		guard let indexPath = coursesTableView.indexPathForRow(at: coursesTableView.convert(location, to: view)),
			let cell = coursesTableView.cellForRow(at: indexPath) else {
				return nil
		}
		guard let destinationViewController = storyboard?.instantiateViewController(withIdentifier: "progressReport") as? ProgressReportViewController else {
			return nil
		}
		let selectedCourse = filteredCourses[indexPath.row]
		destinationViewController.title = selectedCourse.courseName
		destinationViewController.periodID = selectedCourse.periodID
		destinationViewController.preferredContentSize = CGSize(width: 0.0, height: 0.0)
		previewingContext.sourceRect = cell.frame
		return destinationViewController
	}

	func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
		navigationController?.pushViewController(viewControllerToCommit, animated: true)
	}

	// In a storyboard-based application, you will often want to do a little preparation before navigation
	override func prepare(for segue: UIStoryboardSegue, sender: AnyObject?) {
		// Get the new view controller using segue.destinationViewController.
		// Pass the selected object to the new view controller.
		guard let destinationViewController = segue.destinationViewController as? ProgressReportViewController,
			let cell = sender as? CourseTableViewCell,
			let indexPath = coursesTableView.indexPath(for: cell) else {
				assertionFailure("Could not cast destinationViewController to ProgressReportViewController")
				return
		}
		let selectedCourse = filteredCourses[indexPath.row]
		destinationViewController.title = selectedCourse.courseName
		destinationViewController.periodID = selectedCourse.periodID
//		self.destinationViewController = destinationViewController
	}
}
