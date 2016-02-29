//
//  LoopMailViewController.swift
//  break
//
//  Created by Saagar Jha on 1/22/16.
//  Copyright © 2016 Saagar Jha. All rights reserved.
//

import UIKit

class LoopMailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, SchoolLoopLoopMailDelegate {

	let cellIdentifier = "LoopMail"

	var schoolLoop: SchoolLoop!
	var loopMail: [SchoolLoopLoopMail] = []

	var destinationViewController: LoopMailMessageViewController!

	@IBOutlet weak var loopMailTableView: UITableView! {
		didSet {
			loopMailTableView.rowHeight = UITableViewAutomaticDimension
			loopMailTableView.estimatedRowHeight = 80.0
		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		// Do any additional setup after loading the view.
		schoolLoop = SchoolLoop.sharedInstance
		schoolLoop.loopMailDelegate = self
		schoolLoop.getLoopMail()
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	func gotLoopMail(schoolLoop: SchoolLoop, error: SchoolLoopError?) {
		dispatch_async(dispatch_get_main_queue()) {
			if error == nil {
				self.loopMail = schoolLoop.loopMail
				self.loopMailTableView.reloadData()
			}
		}
	}

	@IBAction func openSettings(sender: AnyObject) {
		let viewController = UIStoryboard(name: "Settings", bundle: nil).instantiateViewControllerWithIdentifier("settings")
		navigationController?.presentViewController(viewController, animated: true, completion: nil)
	}

	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}

	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return loopMail.count
	}

	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as? LoopMailTableViewCell else {
			assertionFailure("Could not deque LoopMailTableViewCell")
			return tableView.dequeueReusableCellWithIdentifier(cellIdentifier)!
		}
		cell.subjectLabel.text = loopMail[indexPath.row].subject
		cell.senderLabel.text = loopMail[indexPath.row].sender
		let dateFormatter = NSDateFormatter()
		dateFormatter.dateStyle = .LongStyle
		dateFormatter.timeStyle = .ShortStyle
		cell.dateLabel.text = dateFormatter.stringFromDate(loopMail[indexPath.row].date)
		return cell
	}

	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		let selectedLoopMail = loopMail[indexPath.row]
		destinationViewController.ID = selectedLoopMail.ID
		tableView.deselectRowAtIndexPath(indexPath, animated: true)
	}

	// MARK: - Navigation

	// In a storyboard-based application, you will often want to do a little preparation before navigation
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		// Get the new view controller using segue.destinationViewController.
		// Pass the selected object to the new view controller.
		guard let destinationViewController = segue.destinationViewController as? LoopMailMessageViewController else {
			assertionFailure("Could not cast destinationViewController to LoopMailMessageViewController")
			return
		}
		self.destinationViewController = destinationViewController
	}
}
