//
//  SecurityTableViewController.swift
//  break
//
//  Created by Saagar Jha on 4/27/16.
//  Copyright © 2016 Saagar Jha. All rights reserved.
//

import LocalAuthentication
import UIKit

class SecurityTableViewController: UITableViewController {

	@IBOutlet weak var passwordSwitch: UISwitch!
	@IBOutlet weak var touchIDSwitch: UISwitch!
	@IBOutlet weak var touchIDCell: UITableViewCell!
	@IBOutlet weak var touchIDLabel: UILabel!

	var error: String = ""

	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		passwordSwitch.on = NSUserDefaults.standardUserDefaults().boolForKey("password")
		touchIDSwitch.on = NSUserDefaults.standardUserDefaults().boolForKey("touchID")
		if passwordSwitch.on {
			touchIDCell.userInteractionEnabled = true
			touchIDLabel.enabled = true
			touchIDSwitch.enabled = true
		} else {
			touchIDCell.userInteractionEnabled = false
			touchIDLabel.enabled = false
			touchIDSwitch.enabled = false
		}
		var error: NSError?
		LAContext().canEvaluatePolicy(.DeviceOwnerAuthenticationWithBiometrics, error: &error)
		if let error = error {
			if error.code == LAError.TouchIDNotEnrolled.rawValue {
				self.error = "You don't have an fingers set for TouchID. Please set one in Settings."
				touchIDCell.userInteractionEnabled = false
				touchIDLabel.enabled = false
				touchIDSwitch.on = false
			} else if error.code == LAError.PasscodeNotSet.rawValue {
				self.error = "Your phone doesn't have a passcode or TouchID enabled. Please set one in Settings."
				touchIDCell.userInteractionEnabled = false
				touchIDLabel.enabled = false
				touchIDSwitch.on = false
			} else {
				self.error = "Unsupported"
			}
		}
		tableView.reloadData()
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		// Uncomment the following line to preserve selection between presentations
		// self.clearsSelectionOnViewWillAppear = false

		// Uncomment the following line to display an Edit button in the navigation bar for this view controller.
		// self.navigationItem.rightBarButtonItem = self.editButtonItem()
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	@IBAction func usePassword(sender: UISwitch) {
		if sender.on {
			let alertController = UIAlertController(title: "Set Password", message: "Please enter a password.", preferredStyle: .Alert)
			let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { _ in
				sender.on = false
			}
			let doneAction = UIAlertAction(title: "Done", style: .Default) { _ in
				let schoolLoop = SchoolLoop.sharedInstance
				schoolLoop.keychain.setPassword(alertController.textFields![0].text!, forUsername: "\(schoolLoop.account.username)appPassword")
				self.touchIDCell.userInteractionEnabled = true
				self.touchIDLabel.enabled = true
				self.touchIDSwitch.enabled = true
				NSUserDefaults.standardUserDefaults().setBool(sender.on, forKey: "password")
				NSUserDefaults.standardUserDefaults().synchronize()
			}
			alertController.addAction(cancelAction)
			alertController.addAction(doneAction)
			alertController.addTextFieldWithConfigurationHandler({ textField in
				textField.placeholder = "Enter a password"
				textField.secureTextEntry = true
			})
			presentViewController(alertController, animated: true, completion: nil)
		} else {
			let alertController = UIAlertController(title: "Enter your password", message: "Please enter your current password to disable it. If you've forgotten your password, you can log out of your SchoolLoop account and log back in to clear it.", preferredStyle: .Alert)
			let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { _ in
				sender.on = true
			}
			let doneAction = UIAlertAction(title: "Done", style: .Default) { _ in
				let schoolLoop = SchoolLoop.sharedInstance
				if alertController.textFields![0].text == schoolLoop.keychain.getPasswordForUsername("\(schoolLoop.account.username)appPassword") {
					self.touchIDCell.userInteractionEnabled = false
					self.touchIDLabel.enabled = false
					self.touchIDSwitch.enabled = false
					NSUserDefaults.standardUserDefaults().setBool(sender.on, forKey: "password")
					NSUserDefaults.standardUserDefaults().synchronize()
				} else {
					let alertController = UIAlertController(title: "Incorrect password", message: "The password you entered was incorrect.", preferredStyle: .Alert)
					let okAction = UIAlertAction(title: "Ok", style: .Default, handler: nil)
					alertController.addAction(okAction)
					self.presentViewController(alertController, animated: true, completion: nil)
				}
			}
			alertController.addAction(cancelAction)
			alertController.addAction(doneAction)
			alertController.addTextFieldWithConfigurationHandler({ textField in
				textField.placeholder = "Enter a password"
				textField.secureTextEntry = true
			})
			presentViewController(alertController, animated: true, completion: nil)
		}
	}

	@IBAction func useTouchID(sender: UISwitch) {
		NSUserDefaults.standardUserDefaults().setBool(sender.on, forKey: "touchID")
		NSUserDefaults.standardUserDefaults().synchronize()
	}

	// MARK: - Table view data source

	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		// #warning Incomplete implementation, return the number of sections
		return error == "Unsupported" ? 1 : 2
	}

	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		// #warning Incomplete implementation, return the number of rows
		return 1
	}

	override func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
		if section != 1 {
			return super.tableView(tableView, titleForFooterInSection: section)
		} else {
			return error == "" ? super.tableView(tableView, titleForFooterInSection: section) : error
		}
	}

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

	/*
	 // MARK: - Navigation

	 // In a storyboard-based application, you will often want to do a little preparation before navigation
	 override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
	 // Get the new view controller using segue.destinationViewController.
	 // Pass the selected object to the new view controller.
	 }
	 */

}
