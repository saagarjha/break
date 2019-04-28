//
//  NotificationsTableViewController.swift
//  break
//
//  Created by Saagar Jha on 4/16/17.
//  Copyright © 2017 Saagar Jha. All rights reserved.
//

import UIKit

class NotificationsTableViewController: UITableViewController {

	override func viewDidLoad() {
		super.viewDidLoad()

		// Uncomment the following line to preserve selection between presentations
		// self.clearsSelectionOnViewWillAppear = false

		// Uncomment the following line to display an Edit button in the navigation bar for this view controller.
		// self.navigationItem.rightBarButtonItem = self.editButtonItem()
		setupSelfAsDetailViewController()
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		updateCheckmarks()
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	// MARK: - Table view data source
	/*
	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
	// #warning Incomplete implementation, return the number of sections
	return 0
	}
	
	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
	// #warning Incomplete implementation, return the number of rows
	return 0
	}
	*/

	/*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

	/*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

	/*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

	/*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

	/*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		switch indexPath.row {
		case breakTabIndices.courses.rawValue:
			Preferences.areCoursesNotificationsAllowed.toggle()
		case breakTabIndices.assignments.rawValue:
			Preferences.areAssignmentsNotificationsAllowed.toggle()
		case breakTabIndices.loopMail.rawValue:
			Preferences.areLoopMailNotificationsAllowed.toggle()
		case breakTabIndices.news.rawValue:
			Preferences.areNewsNotificationsAllowed.toggle()
		default:
			assertionFailure("Invalid notification index")
		}
		updateCheckmarks()
	}

	func updateCheckmarks() {
		var notifications = [Int]()
		if Preferences.areCoursesNotificationsAllowed {
			notifications.append(breakTabIndices.courses.rawValue)
		}
		if Preferences.areAssignmentsNotificationsAllowed {
			notifications.append(breakTabIndices.assignments.rawValue)
		}
		if Preferences.areLoopMailNotificationsAllowed {
			notifications.append(breakTabIndices.loopMail.rawValue)
		}
		if Preferences.areNewsNotificationsAllowed {
			notifications.append(breakTabIndices.news.rawValue)
		}
		(0..<4).forEach {
			tableView.cellForRow(at: IndexPath(row: $0, section: 0))?.accessoryType = .none
		}

		if !notifications.isEmpty {
			let replyNotificationAction = UIMutableUserNotificationAction()
			replyNotificationAction.identifier = "Reply"
			replyNotificationAction.title = "Reply"
			replyNotificationAction.activationMode = .foreground

			let replyNotificationCategory = UIMutableUserNotificationCategory()
			replyNotificationCategory.identifier = "ReplyCategory"
			replyNotificationCategory.setActions([replyNotificationAction], for: .default)
			replyNotificationCategory.setActions([replyNotificationAction], for: .minimal)

			UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: [.sound, .alert, .badge], categories: [replyNotificationCategory]))
		}

		notifications.forEach {
			tableView.cellForRow(at: IndexPath(row: $0, section: 0))?.accessoryType = .checkmark
		}
	}

	/*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
