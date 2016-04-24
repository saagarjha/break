//
//  LoginViewController.swift
//  break
//
//  Created by Saagar Jha on 1/18/16.
//  Copyright © 2016 Saagar Jha. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
	let logInSegueIdentifier = "logInSegue"

	var schoolLoop: SchoolLoop!
	var schools: [SchoolLoopSchool] = []

	@IBOutlet weak var schoolNameTextField: UITextField! {
		didSet {
			schoolNameTextField.delegate = self
			schoolNameTextField.autocorrectionType = .No
			schoolNameTextField.autocapitalizationType = .Words
			schoolNameTextField.returnKeyType = .Next
		}
	}
	@IBOutlet weak var usernameTextField: UITextField! {
		didSet {
			usernameTextField.delegate = self
			schoolNameTextField.autocorrectionType = .No
			schoolNameTextField.autocapitalizationType = .None
			schoolNameTextField.returnKeyType = .Next
		}
	}
	@IBOutlet weak var passwordTextField: UITextField! {
		didSet {
			passwordTextField.delegate = self
			passwordTextField.secureTextEntry = true
			passwordTextField.autocorrectionType = .No
			passwordTextField.autocapitalizationType = .None
			passwordTextField.returnKeyType = .Done
		}
	}
	@IBOutlet weak var logInButton: UIButton!
//	var loginActivityIndicatorView: UIActivityIndicatorView!

	override func viewDidLoad() {
		super.viewDidLoad()

		// Do any additional setup after loading the view.
//		loginActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
//		loginActivityIndicatorView.center = view.center
//		view.addSubview(loginActivityIndicatorView)
//		view.sendSubviewToBack(loginActivityIndicatorView)

		schoolLoop = SchoolLoop.sharedInstance
//		schoolLoop.schoolDelegate = self
//		schoolLoop.loginDelegate = self
//		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
		schoolLoop.getSchools() { error in
			if error == .NoError {
				self.schools = self.schoolLoop.schools
				self.schools.sortInPlace()
			}
		}
//		}
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
//
//	func gotSchools(schoolLoop: SchoolLoop, error: SchoolLoopError?) {
//		schools = schoolLoop.schools
//		schools.sortInPlace()
//	}

	@IBAction func logIn(sender: AnyObject) {
//		view.bringSubviewToFront(loginActivityIndicatorView)
//		loginActivityIndicatorView.startAnimating()
//		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
		self.schoolLoop.logIn(self.schoolNameTextField.text ?? "", username: self.usernameTextField.text ?? "", password: self.passwordTextField.text ?? "") { error in
			dispatch_async(dispatch_get_main_queue()) {
				if error == .NoError {
					self.performSegueWithIdentifier(self.logInSegueIdentifier, sender: self)
					var view: UIView?
					if let tabBarController = UIApplication.sharedApplication().delegate?.window??.rootViewController as? UITabBarController,
						viewControllers = tabBarController.viewControllers?.map({ ($0 as? UINavigationController)?.viewControllers[0] }) {
							for viewController in viewControllers {
								if let coursesViewController = viewController as? CoursesViewController {
									view = coursesViewController.view
								}
								if let assignmentsViewController = viewController as? AssignmentsViewController {
									view = assignmentsViewController.view
								}
								if let loopMailViewController = viewController as? LoopMailViewController {
									view = loopMailViewController.view
								}
								if let newsViewController = viewController as? NewsViewController {
									view = newsViewController.view
								}
							}
					}
					if let _ = view as? AnyObject {
						return
					}
				} else {
					let alertController = UIAlertController(title: "Authentication failed", message: "Please check your login credentials and try again.", preferredStyle: .Alert)
					let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
					alertController.addAction(okAction)
					self.presentViewController(alertController, animated: true, completion: nil)
				}

//				self.loginActivityIndicatorView.stopAnimating()
//				self.view.sendSubviewToBack(self.loginActivityIndicatorView)
			}
		}
//		}
	}

//	func loggedIn(schoolLoop: SchoolLoop, error: SchoolLoopError?) {
//		dispatch_async(dispatch_get_main_queue()) {
//			if error == nil {
//				self.performSegueWithIdentifier(self.logInSegueIdentifier, sender: self)
//			} else {
//				let alertController = UIAlertController(title: "Authentication failed", message: "Please check your login credentials and try again.", preferredStyle: .Alert)
//				let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
//				alertController.addAction(okAction)
//				self.presentViewController(alertController, animated: true, completion: nil)
//			}
//			self.loginActivityIndicatorView.stopAnimating()
//			self.view.sendSubviewToBack(self.loginActivityIndicatorView)
//		}
//	}

	func textFieldShouldReturn(textField: UITextField) -> Bool {
		if textField === schoolNameTextField {
			textFieldDidEndEditing(textField)
			usernameTextField.becomeFirstResponder()
		} else if textField === usernameTextField {
			passwordTextField.becomeFirstResponder()
		} else {
			logIn(logInButton)
			return false
		}
		return true
	}

	func textFieldDidBeginEditing(textField: UITextField) {
		textField.selectedTextRange = textField.textRangeFromPosition(textField.beginningOfDocument, toPosition: textField.endOfDocument)
	}

	func textFieldDidEndEditing(textField: UITextField) {
		if textField === schoolNameTextField {
			textField.textColor = nil
		}
	}

	func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
		if textField === schoolNameTextField {
			guard let attributedText = textField.attributedText?.mutableCopy() as? NSMutableAttributedString else {
				assertionFailure("Could not cast mutableCopy to NSMutableAttributedString")
				return false
			}
			var attributedRange = NSMakeRange(0, 0)
			if attributedText.length > 0 {
				attributedText.attribute(NSForegroundColorAttributeName, atIndex: 0, longestEffectiveRange: &attributedRange, inRange: NSMakeRange(0, attributedText.length))
			}
			var schoolName: String!
			if range.location <= attributedRange.location + attributedRange.length && range.length <= attributedRange.length {
				schoolName = (attributedText.string as NSString).substringWithRange(attributedRange)
			} else {
				schoolName = attributedText.string
			}
			schoolName = (schoolName as NSString).stringByReplacingCharactersInRange(range, withString: string)
			let suggestion = getSchoolSuggestion(schoolName)
			let attributedString = NSMutableAttributedString(string: suggestion)
			attributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor.grayColor(), range: NSMakeRange(schoolName.characters.count, suggestion.characters.count - schoolName.characters.count))
			textField.attributedText = attributedString
			textField.selectedTextRange = textField.textRangeFromPosition(textField.positionFromPosition(textField.beginningOfDocument, offset: range.location + string.characters.count)!, toPosition: textField.positionFromPosition(textField.beginningOfDocument, offset: range.location + string.characters.count)!)
			return false
		}
		return true
	}

	func getSchoolSuggestion(schoolName: String) -> String {
		var low = schools.startIndex
		var high = schools.endIndex
		var mid: Int
		while low < high {
			mid = low.advancedBy(low.distanceTo(high) / 2)
			let name = schools[mid].name
			if name.lowercaseString.hasPrefix(schoolName.lowercaseString) {
				return name
			} else if name > schoolName {
				high = mid
			} else if name < schoolName {
				low = mid.advancedBy(1)
			}
		}
		return schoolName
	}

	/*
	 // MARK: - Navigation

	 // In a storyboard-based application, you will often want to do a little preparation before navigation
	 override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
	 // Get the new view controller using segue.destinationViewController.
	 // Pass the selected object to the new view controller.
	 }
	 */
}
