//
//  AccountTableViewController.swift
//  break
//
//  Created by Saagar Jha on 1/26/16.
//  Copyright © 2016 Saagar Jha. All rights reserved.
//

import UIKit

class AccountTableViewController: UITableViewController {

	var schoolLoop: SchoolLoop!

	@IBOutlet weak var accountNameLabel: UILabel!
	@IBOutlet weak var schoolNameLabel: UILabel!
	@IBOutlet weak var districtNameLabel: UILabel!
	@IBOutlet weak var emailLabel: UILabel!

	override func viewDidLoad() {
		super.viewDidLoad()

		// Uncomment the following line to preserve selection between presentations
		// self.clearsSelectionOnViewWillAppear = false

		// Uncomment the following line to display an Edit button in the navigation bar for this view controller.
		// self.navigationItem.rightBarButtonItem = self.editButtonItem()
		setupSelfAsDetailViewController()

		schoolLoop = SchoolLoop.sharedInstance
		accountNameLabel.text = schoolLoop.account.fullName
		schoolNameLabel.text = schoolLoop.school.name
		districtNameLabel.text = schoolLoop.school.districtName
		emailLabel.text = schoolLoop.account.email
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
	 override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
	 let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

	 // Configure the cell...

	 return cell
	 }
	 */

	/*
	 // Override to support conditional editing of the table view.
	 override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
	 // Return false if you do not want the specified item to be editable.
	 return true
	 }
	 */

	/*
	 // Override to support editing the table view.
	 override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
	 if editingStyle == .Delete {
	 // Delete the row from the data source
	 tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
	 } else if editingStyle == .Insert {
	 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
	 }
	 }
	 */

	/*
	 // Override to support rearranging the table view.
	 override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

	 }
	 */

	/*
	 // Override to support conditional rearranging of the table view.
	 override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
	 // Return false if you do not want the item to be re-orderable.
	 return true
	 }
	 */

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if indexPath.row == 4 {
			schoolLoop.logOut()
			let appDelegate = UIApplication.shared.delegate as? AppDelegate
			appDelegate?.clearCache()
			appDelegate?.showLogout()
		}
		tableView.deselectRow(at: indexPath, animated: true)
	}

	/*
	 // MARK: - Navigation

	 // In a storyboard-based application, you will often want to do a little preparation before navigation
	 override func prepareForSegue(segue: UIStoryboardSegue, sender: Any?) {
	 // Get the new view controller using segue.destinationViewController.
	 // Pass the selected object to the new view controller.
	 }
	 */
}
