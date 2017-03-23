//
//  AssignmentsViewController.swift
//  break
//
//  Created by Saagar Jha on 1/18/16.
//  Copyright © 2016 Saagar Jha. All rights reserved.
//

import UIKit

class AssignmentsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchControllerDelegate, UISearchResultsUpdating, UIViewControllerPreviewingDelegate {

	let cellIdentifier = "assignment"

	var schoolLoop: SchoolLoop!
	var assignments = [Date: [SchoolLoopAssignment]]()
	var filteredAssignments = [Date: [SchoolLoopAssignment]]()
	var filteredAssignmentDueDates: [Date] = []

	var destinationViewController: AssignmentDescriptionViewController!

	@IBOutlet weak var assignmentsTableView: UITableView! {
		didSet {
			assignmentsTableView.rowHeight = UITableViewAutomaticDimension
			assignmentsTableView.estimatedRowHeight = 80.0
			refreshControl.addTarget(self, action: #selector(AssignmentsViewController.refresh(_:)), for: .valueChanged)
			if #available(iOS 10.0, *) {
				assignmentsTableView.refreshControl = refreshControl
			} else {
				assignmentsTableView.addSubview(refreshControl)
				assignmentsTableView.backgroundView = UIView()
				assignmentsTableView.backgroundView?.backgroundColor = .clear
			}
		}
	}
	let refreshControl = UIRefreshControl()
	let searchController = UISearchController(searchResultsController: nil)

	deinit {
		searchController.loadViewIfNeeded()
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		assignments = SchoolLoop.sharedInstance.assignmentsWithDueDates
		updateSearchResults(for: searchController)
		navigationController?.hidesBarsOnSwipe = false
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		// Do any additional setup after loading the view.
		definesPresentationContext = true
		searchController.searchResultsUpdater = self
		searchController.delegate = self
		searchController.dimsBackgroundDuringPresentation = false
		assignmentsTableView.tableHeaderView = searchController.searchBar
		schoolLoop = SchoolLoop.sharedInstance
		if traitCollection.forceTouchCapability == .available {
			registerForPreviewing(with: self, sourceView: assignmentsTableView)
		}
		refresh(self)
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	func refresh(_ sender: AnyObject) {
		UIApplication.shared.isNetworkActivityIndicatorVisible = true
		schoolLoop.getAssignments { (_, error) in
			DispatchQueue.main.async {
				UIApplication.shared.isNetworkActivityIndicatorVisible = false
				if error == .noError {
					(UIApplication.shared.delegate as? AppDelegate)?.saveCache()
					self.assignments = self.schoolLoop.assignmentsWithDueDates
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
		return filteredAssignments.keys.count
	}

	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "EEEE, MMMM d"
		return dateFormatter.string(from: filteredAssignmentDueDates[section])
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return filteredAssignments[filteredAssignmentDueDates[section]]?.count ?? 0
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? AssignmentTableViewCell else {
			assertionFailure("Could not deque AssignmentTableViewCell")
			return tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
		}
		let section = indexPath.section
		let row = indexPath.row
		let assignment = filteredAssignments[filteredAssignmentDueDates[section]]?[row]
		if assignment?.isCompleted ?? false {
			let titleText = NSAttributedString(string: assignment?.title ?? "", attributes: [NSStrikethroughStyleAttributeName: NSNumber(value: NSUnderlineStyle.styleSingle.rawValue)])
			let courseNameText = NSAttributedString(string: assignment?.courseName ?? "", attributes: [NSStrikethroughStyleAttributeName: NSNumber(value: NSUnderlineStyle.styleSingle.rawValue)])
			cell.titleLabel.attributedText = titleText
			cell.courseNameLabel.attributedText = courseNameText
		} else {
			cell.titleLabel.text = assignment?.title
			cell.courseNameLabel.text = assignment?.courseName
		}
		return cell
	}

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
	}

	func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
		let completeAction = UITableViewRowAction(style: .normal, title: "Mark\nDone") { _, indexPath in
			let assignment = self.filteredAssignments[self.filteredAssignmentDueDates[indexPath.section]]?[indexPath.row]
			assignment?.isCompleted = !(assignment?.isCompleted ?? false)
			DispatchQueue.main.async {
				tableView.reloadData()
			}
		}
		completeAction.backgroundColor = view.tintColor
		return [completeAction]
	}

	func updateSearchResults(for searchController: UISearchController) {
		let filter = searchController.searchBar.text?.lowercased() ?? ""
		if filter != "" {
			filteredAssignments.removeAll()
			for assignment in Array(assignments.values).flatMap({ $0 }) {
				if assignment.title.lowercased().contains(filter) || assignment.courseName.lowercased().contains(filter) {
					var assignments = filteredAssignments[assignment.dueDate] ?? []
					assignments.append(assignment)
					filteredAssignments[assignment.dueDate] = assignments
				}
			}
		} else {
			filteredAssignments = assignments
		}
		filteredAssignmentDueDates = Array(filteredAssignments.keys)
		filteredAssignmentDueDates.sort {
			$0.compare($1) == .orderedAscending
		}
		DispatchQueue.main.async {
			self.assignmentsTableView.reloadData()
		}
	}

	// MARK: - Navigation

	func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
		guard let indexPath = assignmentsTableView.indexPathForRow(at: location),
			let cell = assignmentsTableView.cellForRow(at: indexPath) else {
				return nil
		}
		guard let destinationViewController = storyboard?.instantiateViewController(withIdentifier: "assignmentDescription") as? AssignmentDescriptionViewController else {
			return nil
		}
		let selectedAssignment = filteredAssignments[filteredAssignmentDueDates[indexPath.section]]![indexPath.row]
		destinationViewController.iD = selectedAssignment.iD
		destinationViewController.preferredContentSize = CGSize(width: 0.0, height: 0.0)
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
		guard let destinationViewController = segue.destination as? AssignmentDescriptionViewController,
			let cell = sender as? AssignmentTableViewCell,
			let indexPath = assignmentsTableView.indexPath(for: cell) else {
				assertionFailure("Could not cast destinationViewController to AssignmentDescriptionViewController")
				return
		}
		let selectedAssignment = filteredAssignments[filteredAssignmentDueDates[indexPath.section]]![indexPath.row]
		destinationViewController.iD = selectedAssignment.iD
		self.destinationViewController = destinationViewController
	}
}
