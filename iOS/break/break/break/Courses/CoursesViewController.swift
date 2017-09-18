//
//  CoursesViewController.swift
//  break
//
//  Created by Saagar Jha on 1/19/16.
//  Copyright © 2016 Saagar Jha. All rights reserved.
//

import UIKit

class CoursesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchResultsUpdating, UIViewControllerPreviewingDelegate {

	static let cellIdentifier = "course"

	var schoolLoop: SchoolLoop!
	var courses = [SchoolLoopCourse]()
	var filteredCourses = [SchoolLoopCourse]()

	@IBOutlet weak var showHideBarButtonItem: UIBarButtonItem! {
		didSet {
			if !Preferences.hideGrades {
				showHideBarButtonItem.image = #imageLiteral(resourceName: "HideBarButtonIcon")
			} else {
				showHideBarButtonItem.image = #imageLiteral(resourceName: "ShowBarButtonIcon")
			}
		}
	}
	@IBOutlet weak var coursesTableView: UITableView! {
		didSet {
			breakShared.autoresizeTableViewCells(for: coursesTableView)
			breakShared.add(refreshControl, to: coursesTableView)
			refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
		}
	}
	let refreshControl = UIRefreshControl()
	let searchController = UISearchController(searchResultsController: nil)

	override func viewDidLoad() {
		super.viewDidLoad()

		// Do any additional setup after loading the view.
		addSearchBar(from: searchController, to: coursesTableView)
		setupSelfAsMasterViewController()
		
		schoolLoop = SchoolLoop.sharedInstance
		refresh(self)
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		courses = SchoolLoop.sharedInstance.courses
		updateSearchResults(for: searchController)
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	@objc func refresh(_ sender: Any) {
		UIApplication.shared.isNetworkActivityIndicatorVisible = true
		schoolLoop.getCourses { (_, error) in
			DispatchQueue.main.async { [weak self] in
				guard let `self` = self else {
					return
				}
				UIApplication.shared.isNetworkActivityIndicatorVisible = false
				if error == .noError {
					(UIApplication.shared.delegate as? AppDelegate)?.saveCache()
					`self`.courses = `self`.schoolLoop.courses
					`self`.updateSearchResults(for: `self`.searchController)
				}
				// Otherwise the refresh control dismiss animation doesn't work
				`self`.refreshControl.perform(#selector(UIRefreshControl.endRefreshing), with: nil, afterDelay: 0)
			}
		}

	}

	@IBAction func openSettings(_ sender: Any) {
		let viewController = UIStoryboard(name: "Settings", bundle: nil).instantiateViewController(withIdentifier: "settings")
		navigationController?.present(viewController, animated: true, completion: nil)
	}

	@IBAction func showHideGrades(_ sender: Any) {
		if Preferences.hideGrades {
			showHideBarButtonItem.image = #imageLiteral(resourceName: "HideBarButtonIcon")
		} else {
			showHideBarButtonItem.image = #imageLiteral(resourceName: "ShowBarButtonIcon")
		}
		Preferences.hideGrades = !Preferences.hideGrades
		updateSearchResults(for: searchController)
	}

	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return filteredCourses.count
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: CoursesViewController.cellIdentifier, for: indexPath) as? CourseTableViewCell else {
			assertionFailure("Could not deque CourseTableViewCell")
			return tableView.dequeueReusableCell(withIdentifier: CoursesViewController.cellIdentifier, for: indexPath)
		}
		let course = filteredCourses[indexPath.row]
		cell.courseNameDiscriminatorView.backgroundColor = UIColor(string: course.courseName)
		cell.periodLabel.text = course.period
		cell.courseNameLabel.text = course.courseName
		cell.teacherNameLabel.text = course.teacherName
		if !Preferences.hideGrades {
			cell.gradeLabel.text = course.grade
			cell.scoreLabel.text = course.score
		} else {
			cell.gradeLabel.text = "Grades"
			cell.scoreLabel.text = "Hidden"
		}
		
		// Try to keep the cell's labels from having extraneous line breaks
		// This can occur after a show/hide event
		[cell.courseNameLabel, cell.teacherNameLabel].forEach {
			$0?.numberOfLines = 1
			$0?.numberOfLines = 0
		}
		
		return cell
	}

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
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
		DispatchQueue.main.async { [unowned self] in
			self.coursesTableView.reloadData()
		}
	}

	// MARK: - Navigation

	func openProgressReport(for course: SchoolLoopCourse) {
		guard let progressReportViewController = storyboard?.instantiateViewController(withIdentifier: "progressReport") as? ProgressReportViewController else {
			assertionFailure("Could not create ProgressReportViewController")
			return
		}
		progressReportViewController.title = course.courseName
		progressReportViewController.titleButton.setTitle(course.courseName, for: .normal)
		progressReportViewController.periodID = course.periodID
		navigationController?.pushViewController(progressReportViewController, animated: true)
	}
	
	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		setupForceTouch(originatingFrom: coursesTableView)
	}

	func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
		guard let indexPath = coursesTableView.indexPathForRow(at: location),
			let cell = coursesTableView.cellForRow(at: indexPath) else {
				return nil
		}
		guard let destinationViewController = storyboard?.instantiateViewController(withIdentifier: "progressReport") as? ProgressReportViewController else {
			return nil
		}
		let selectedCourse = filteredCourses[indexPath.row]
		destinationViewController.titleButton.setTitle(selectedCourse.courseName, for: .normal)
		destinationViewController.periodID = selectedCourse.periodID
		destinationViewController.preferredContentSize = .zero
		previewingContext.sourceRect = cell.frame
		return destinationViewController
	}

	func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
		navigationController?.pushViewController(viewControllerToCommit, animated: true)
	}

	// In a storyboard-based application, you will often want to do a little preparation before navigation
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		// Get the new view controller using segue.destinationViewController.
		// Pass the selected object to the new view controller.
		guard let destinationViewController = (segue.destination as? UINavigationController)?.topViewController as? ProgressReportViewController,
			let cell = sender as? CourseTableViewCell,
			let indexPath = coursesTableView.indexPath(for: cell) else {
				assertionFailure("Could not cast destinationViewController to ProgressReportViewController")
				return
		}
		let selectedCourse = filteredCourses[indexPath.row]
		destinationViewController.title = selectedCourse.courseName
		destinationViewController.titleButton.setTitle(selectedCourse.courseName, for: .normal)
		destinationViewController.periodID = selectedCourse.periodID
	}
}
