//
//  AssignmentsViewController.swift
//  break
//
//  Created by Saagar Jha on 1/18/16.
//  Copyright © 2016 Saagar Jha. All rights reserved.
//

import UIKit

class AssignmentsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIViewControllerPreviewingDelegate {

	let cellIdentifier = "assignment"

	var schoolLoop: SchoolLoop!
	var assignments: [NSDate: [SchoolLoopAssignment]] = [:]
	var assignmentDueDates: [NSDate] = []

	var destinationViewController: AssignmentDescriptionViewController!

	@IBOutlet weak var assignmentsTableView: UITableView! {
		didSet {
			assignmentsTableView.rowHeight = UITableViewAutomaticDimension
			assignmentsTableView.estimatedRowHeight = 80.0
			refreshControl.addTarget(self, action: #selector(AssignmentsViewController.refresh(_:)), forControlEvents: .ValueChanged)
			assignmentsTableView.addSubview(refreshControl)
		}
	}
	let refreshControl = UIRefreshControl()

//    override func viewWillAppear(animated: Bool) {
//        super.viewWillAppear(animated)
//        navigationController?.hidesBarsOnSwipe = false
//    }

	override func viewDidLoad() {
		super.viewDidLoad()

		// Do any additional setup after loading the view.
		schoolLoop = SchoolLoop.sharedInstance
        if traitCollection.forceTouchCapability == .Available {
            registerForPreviewingWithDelegate(self, sourceView: view)
        }
//		schoolLoop.assignmentDelegate = self
//		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
		refresh(self)
//		}
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

//	func gotAssignments(schoolLoop: SchoolLoop, error: SchoolLoopError?) {
//		dispatch_async(dispatch_get_main_queue()) {
//			if error == nil {
//				self.assignments = schoolLoop.assignmentsWithDueDates
//				self.assignmentsTableView.reloadData()
//			}
//			self.refreshControl.performSelector(#selector(UIRefreshControl.endRefreshing), withObject: nil, afterDelay: 0)
//		}
//	}

	func refresh(sender: AnyObject) {
		dispatch_async(dispatch_get_main_queue()) {
			self.schoolLoop.getAssignments() { (_, error) in
				dispatch_async(dispatch_get_main_queue()) {
					if error == .NoError {
						self.assignments = self.schoolLoop.assignmentsWithDueDates
						self.assignmentDueDates = Array(self.assignments.keys)
						self.assignmentDueDates.sortInPlace({ $0.compare($1) == NSComparisonResult.OrderedAscending })
						self.assignmentsTableView.reloadData()
					}
					self.refreshControl.performSelector(#selector(UIRefreshControl.endRefreshing), withObject: nil, afterDelay: 0)
				}
			}
		}
	}

	@IBAction func openSettings(sender: AnyObject) {
		let viewController = UIStoryboard(name: "Settings", bundle: nil).instantiateViewControllerWithIdentifier("settings")
		navigationController?.presentViewController(viewController, animated: true, completion: nil)
	}

	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return assignments.keys.count
	}

	func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		let dateFormatter = NSDateFormatter()
		dateFormatter.dateFormat = "EEEE, MMMM d"
		return dateFormatter.stringFromDate(assignmentDueDates[section])
	}

	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return assignments[assignments.keys.sort({ $0.compare($1) == NSComparisonResult.OrderedAscending })[section]]!.count
	}

	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as? AssignmentTableViewCell else {
			assertionFailure("Could not deque AssignmentTableViewCell")
			return tableView.dequeueReusableCellWithIdentifier(cellIdentifier)!
		}
		let section = indexPath.section
		let row = indexPath.row
		let assignment = assignments[assignmentDueDates[section]]?[row]
		cell.titleLabel.text = assignment?.title
		cell.courseNameLabel.text = assignment?.courseName
		return cell
	}

	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		let selectedAssignment = assignments[assignmentDueDates[indexPath.section]]![indexPath.row]
		destinationViewController.iD = selectedAssignment.iD
		tableView.deselectRowAtIndexPath(indexPath, animated: true)
	}

	// MARK: - Navigation
    
    func previewingContext(previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = assignmentsTableView.indexPathForRowAtPoint(location),
            cell = assignmentsTableView.cellForRowAtIndexPath(indexPath) else {
                return nil
        }
        
        guard let destinationViewController = storyboard?.instantiateViewControllerWithIdentifier("assignmentDescription") as? AssignmentDescriptionViewController else {
            return nil
        }
        let selectedAssignment = assignments[assignmentDueDates[indexPath.section]]![indexPath.row]
        destinationViewController.iD = selectedAssignment.iD
        destinationViewController.preferredContentSize = CGSize(width: 0.0, height: 0.0)
        previewingContext.sourceRect = cell.frame
        return destinationViewController
    }
    
    func previewingContext(previewingContext: UIViewControllerPreviewing, commitViewController viewControllerToCommit: UIViewController) {
        navigationController?.pushViewController(viewControllerToCommit, animated: true)
    }

	// In a storyboard-based application, you will often want to do a little preparation before navigation
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		// Get the new view controller using segue.destinationViewController.
		// Pass the selected object to the new view controller.
		guard let destinationViewController = segue.destinationViewController as? AssignmentDescriptionViewController else {
			assertionFailure("Could not cast destinationViewController to AssignmentDescriptionViewController")
			return
		}
		self.destinationViewController = destinationViewController
	}
}
