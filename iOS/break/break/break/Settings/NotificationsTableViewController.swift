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

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 4
    }

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
		switch  indexPath.row {
		case 0:
			Preferences.areCoursesNotificationsAllowed = !Preferences.areCoursesNotificationsAllowed
		case 1:
			Preferences.areAssignmentsNotificationsAllowed = !Preferences.areAssignmentsNotificationsAllowed
		case 2:
			Preferences.areLoopMailNotificationsAllowed = !Preferences.areLoopMailNotificationsAllowed
		case 3:
			Preferences.areNewsNotificationsAllowed = !Preferences.areNewsNotificationsAllowed
		default:
			assertionFailure("Invalid notification index")
		}
		updateCheckmarks()
	}
	
	func updateCheckmarks() {
		var notifications = [Int]()
		if Preferences.areCoursesNotificationsAllowed {
			notifications.append(0)
		}
		if Preferences.areAssignmentsNotificationsAllowed {
			notifications.append(1)
		}
		if Preferences.areLoopMailNotificationsAllowed {
			notifications.append(2)
		}
		if Preferences.areNewsNotificationsAllowed {
			notifications.append(3)
		}
		[0, 1, 2, 3].forEach {
			tableView.cellForRow(at: IndexPath(row: $0, section: 0))?.accessoryType = .none
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
