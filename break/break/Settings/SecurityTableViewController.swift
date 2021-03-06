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

	@IBOutlet weak var passwordCell: UITableViewCell! {
		didSet {
			passwordCell.accessoryView = passwordSwitch
		}
	}
	let passwordSwitch: UISwitch = {
		let passwordSwitch = UISwitch()
		passwordSwitch.addTarget(self, action: #selector(usePassword), for: .valueChanged)
		return passwordSwitch
	}()
	@IBOutlet weak var biometricAuthenticationCell: UITableViewCell! {
		didSet {
			biometricAuthenticationCell.accessoryView = biometricAuthenticationSwitch
		}
	}
	@IBOutlet weak var biometricAuthenticationLabel: UILabel!
	let biometricAuthenticationSwitch: UISwitch = {
		let biometricAuthenticationSwitch = UISwitch()
		biometricAuthenticationSwitch.addTarget(self, action: #selector(useBiometricAuthentication), for: .valueChanged)
		return biometricAuthenticationSwitch
	}()

	var error: String = ""

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
		updateTableView()
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	@IBAction func usePassword(_ sender: UISwitch) {
		if sender.isOn {
			let alertController = UIAlertController(title: "Set Password", message: "Please enter a password.", preferredStyle: .alert)
			let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
				sender.isOn = false
			}
			let doneAction = UIAlertAction(title: "Done", style: .default) { _ in
				let schoolLoop = SchoolLoop.sharedInstance
				_ = schoolLoop.keychain.addPassword(alertController.textFields?.first?.text ?? "", forUsername: "\(schoolLoop.account.username)appPassword")
				Preferences.isPasswordSet = sender.isOn
				self.updateTableView()
			}
			alertController.addAction(cancelAction)
			alertController.addAction(doneAction)
			alertController.addTextField { textField in
				textField.placeholder = "Enter a password"
				textField.isSecureTextEntry = true
			}
			present(alertController, animated: true, completion: nil)
		} else {
			let alertController = UIAlertController(title: "Enter your password", message: "Please enter your current password to disable it. If you've forgotten your password, you can log out of your School Loop account and log back in to clear it.", preferredStyle: .alert)
			let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
				sender.isOn = true
			}
			let doneAction = UIAlertAction(title: "Done", style: .default) { _ in
				let schoolLoop = SchoolLoop.sharedInstance
				if alertController.textFields?.first?.text == schoolLoop.keychain.getPassword(forUsername: "\(schoolLoop.account.username)appPassword") {
					Preferences.isPasswordSet = sender.isOn
					self.updateTableView()
				} else {
					let alertController = UIAlertController(title: "Incorrect password", message: "The password you entered was incorrect.", preferredStyle: .alert)
					let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
					alertController.addAction(okAction)
					self.present(alertController, animated: true, completion: nil)
					sender.isOn = true
				}
			}
			alertController.addAction(cancelAction)
			alertController.addAction(doneAction)
			alertController.addTextField { textField in
				textField.placeholder = "Enter a password"
				textField.isSecureTextEntry = true
			}
			present(alertController, animated: true, completion: nil)
		}
	}

	@objc func useBiometricAuthentication(_ sender: UISwitch) {
		Preferences.canUseTouchID = sender.isOn
	}

	// MARK: - Table view data source

	override func numberOfSections(in tableView: UITableView) -> Int {
		return error == "Unsupported" ? 1 : 2
	}

	/*
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
	// #warning Incomplete implementation, return the number of rows
	return 0
	}
	*/

	override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
		guard section == 1 else {
			return super.tableView(tableView, titleForFooterInSection: section)
		}
		return error == "" ? super.tableView(tableView, titleForFooterInSection: section) : error
	}

	func updateTableView() {
		passwordSwitch.isOn = Preferences.isPasswordSet
		biometricAuthenticationSwitch.isOn = Preferences.canUseTouchID
		if passwordSwitch.isOn {
			biometricAuthenticationCell.isUserInteractionEnabled = true
			biometricAuthenticationLabel.isEnabled = true
			biometricAuthenticationSwitch.isEnabled = true
		} else {
			biometricAuthenticationCell.isUserInteractionEnabled = false
			biometricAuthenticationLabel.isEnabled = false
			biometricAuthenticationSwitch.isEnabled = false
		}
		var error: NSError?
		LAContext().canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
		if let error = error {
			if error.code == LAError.touchIDNotEnrolled.rawValue {
				self.error = "You don't have any fingers set for Touch ID or a face set for Face ID. Please set one in Settings."
				biometricAuthenticationCell.isUserInteractionEnabled = false
				biometricAuthenticationLabel.isEnabled = false
				biometricAuthenticationSwitch.isEnabled = false
			} else if error.code == LAError.passcodeNotSet.rawValue {
				self.error = "Your phone doesn't have a passcode, Touch ID or Face ID enabled. Please set one in Settings."
				biometricAuthenticationCell.isUserInteractionEnabled = false
				biometricAuthenticationLabel.isEnabled = false
				biometricAuthenticationSwitch.isEnabled = false
			} else {
				self.error = "Unsupported"
			}
		}
		tableView.reloadData()
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
	 override func prepareForSegue(segue: UIStoryboardSegue, sender: Any?) {
	 // Get the new view controller using segue.destinationViewController.
	 // Pass the selected object to the new view controller.
	 }
	 */

}
