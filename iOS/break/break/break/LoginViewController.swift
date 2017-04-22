//
//  LoginViewController.swift
//  break
//
//  Created by Saagar Jha on 1/18/16.
//  Copyright © 2016 Saagar Jha. All rights reserved.
//

import SafariServices
import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
	let logInSegueIdentifier = "logInSegue"

	var schoolLoop: SchoolLoop!
	var schools = [SchoolLoopSchool]()

	@IBOutlet weak var loginScrollView: UIScrollView!
	@IBOutlet weak var loginViewHeightConstraint: NSLayoutConstraint!
	@IBOutlet weak var breakStackView: UIStackView!
	@IBOutlet weak var schoolNameTextField: UITextField! {
		didSet {
			schoolNameTextField.delegate = self
		}
	}
	@IBOutlet weak var usernameTextField: UITextField! {
		didSet {
			usernameTextField.delegate = self
		}
	}
	@IBOutlet weak var passwordTextField: UITextField! {
		didSet {
			passwordTextField.delegate = self
			passwordTextField.isSecureTextEntry = true
		}
	}
	@IBOutlet weak var logInButton: UIButton!
	@IBOutlet weak var forgotButton: UIButton!
	@IBOutlet weak var privacyPolicyButton: UIButton!

	var runAnimation = true

	override func viewDidLoad() {
		super.viewDidLoad()

		// Do any additional setup after loading the view.
		navigationController?.setNavigationBarHidden(true, animated: false)
		
		NotificationCenter.default.addObserver(self, selector: #selector(LoopMailComposeViewController.keyboardWillChange(notification:)), name: .UIKeyboardWillShow, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(LoopMailComposeViewController.keyboardWillChange(notification:)), name: .UIKeyboardWillHide, object: nil)

		schoolLoop = SchoolLoop.sharedInstance
		UIApplication.shared.isNetworkActivityIndicatorVisible = true
		schoolLoop.getSchools { error in
			UIApplication.shared.isNetworkActivityIndicatorVisible = false
			if error == .noError {
				self.schools = self.schoolLoop.schools
				self.schools.sort()
			}
		}
		breakStackView.alpha = 0
		schoolNameTextField.alpha = 0
		usernameTextField.alpha = 0
		passwordTextField.alpha = 0
		logInButton.alpha = 0
		forgotButton.alpha = 0
		privacyPolicyButton.alpha = 0
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		if runAnimation {
			breakStackView.alpha = 0
			schoolNameTextField.alpha = 0
			usernameTextField.alpha = 0
			passwordTextField.alpha = 0
			logInButton.alpha = 0
			forgotButton.alpha = 0
			privacyPolicyButton.alpha = 0
			let dy = passwordTextField.frame.midY - schoolNameTextField.frame.midY
			schoolNameTextField.frame = schoolNameTextField.frame.offsetBy(dx: 0, dy: dy)
			usernameTextField.frame = usernameTextField.frame.offsetBy(dx: 0, dy: dy)
			passwordTextField.frame = passwordTextField.frame.offsetBy(dx: 0, dy: dy)
			logInButton.frame = logInButton.frame.offsetBy(dx: 0, dy: dy)
			UIView.animate(withDuration: 1, delay: 0, options: .curveEaseInOut, animations: {
				self.breakStackView.alpha = 1
				self.forgotButton.alpha = 1
				self.privacyPolicyButton.alpha = 1
			}, completion: nil)
			UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
				self.schoolNameTextField.frame = self.schoolNameTextField.frame.offsetBy(dx: 0, dy: -dy)
				self.schoolNameTextField.alpha = 1
			}, completion: nil)
			UIView.animate(withDuration: 0.5, delay: 0.1, options: .curveEaseInOut, animations: {
				self.usernameTextField.frame = self.usernameTextField.frame.offsetBy(dx: 0, dy: -dy)
				self.usernameTextField.alpha = 1
			}, completion: nil)
			UIView.animate(withDuration: 0.5, delay: 0.2, options: .curveEaseInOut, animations: {
				self.passwordTextField.frame = self.passwordTextField.frame.offsetBy(dx: 0, dy: -dy)
				self.passwordTextField.alpha = 1
			}, completion: nil)
			UIView.animate(withDuration: 0.5, delay: 0.3, options: .curveEaseInOut, animations: {
				self.logInButton.frame = self.logInButton.frame.offsetBy(dx: 0, dy: -dy)
				self.logInButton.alpha = 1
			}, completion: nil)
		}
		runAnimation = false
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	@IBAction func logIn(_ sender: AnyObject) {
		UIApplication.shared.isNetworkActivityIndicatorVisible = true
		logInButton.isEnabled = false
		logInButton.alpha = 0.5
		self.schoolLoop.logIn(withSchoolName: self.schoolNameTextField.text ?? "", username: self.usernameTextField.text ?? "", password: self.passwordTextField.text ?? "") { error in
			DispatchQueue.main.async {
				UIApplication.shared.isNetworkActivityIndicatorVisible = false
				if error == .noError {
					(UIApplication.shared.delegate as? AppDelegate)?.saveCache()
					let storybard = UIStoryboard(name: "Main", bundle: nil)
					let tabBarController = storybard.instantiateViewController(withIdentifier: "tab")
					let oldView = UIScreen.main.snapshotView(afterScreenUpdates: false)
					tabBarController.view.addSubview(oldView)
					UIApplication.shared.keyWindow?.rootViewController = tabBarController
					UIView.animate(withDuration: 0.25, animations: {
						oldView.alpha = 0
					}, completion: { _ in
						oldView.removeFromSuperview()
					})
					var view: UIView?
					if let tabBarController = UIApplication.shared.delegate?.window??.rootViewController as? UITabBarController,
						let viewControllers = tabBarController.viewControllers?.flatMap({ ($0 as? UINavigationController)?.viewControllers.first }) {
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
					if let _ = view {
						return
					}
				} else if error == .networkError {
					let alertController = UIAlertController(title: "Network error", message: "There was an issue accessing SchoolLoop. Please try again.", preferredStyle: .alert)
					let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
					alertController.addAction(okAction)
					self.present(alertController, animated: true, completion: nil)
				} else {
					let alertController = UIAlertController(title: "Authentication failed", message: "Please check your login credentials and try again.", preferredStyle: .alert)
					let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
					alertController.addAction(okAction)
					self.present(alertController, animated: true, completion: nil)
				}
				self.logInButton.isEnabled = true
				self.logInButton.alpha = 1
			}
		}
	}

	@IBAction func forgot(_ sender: AnyObject) {
		let safariViewController = SFSafariViewController(url: SchoolLoopConstants.forgotURL)
		present(safariViewController, animated: true, completion: nil)
	}

	@IBAction func privacyPolicy(_ sender: Any) {
		let safariViewController = SFSafariViewController(url: URL(string: "https://saagarjha.com/projects/break/privacy-policy/")!)
		present(safariViewController, animated: true, completion: nil)
	}

	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		if textField === schoolNameTextField {
			textFieldDidEndEditing(textField)
			usernameTextField.becomeFirstResponder()
		} else if textField === usernameTextField {
			passwordTextField.becomeFirstResponder()
		} else {
			view.endEditing(true)
			logIn(logInButton)
			return false
		}
		return true
	}

	func textFieldDidBeginEditing(_ textField: UITextField) {
		textField.selectedTextRange = textField.textRange(from: textField.beginningOfDocument, to: textField.endOfDocument)
	}

	func textFieldDidEndEditing(_ textField: UITextField) {
		if textField === schoolNameTextField {
			textField.textColor = nil
		}
	}

	func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
		if textField === schoolNameTextField {
			guard let attributedText = textField.attributedText?.mutableCopy() as? NSMutableAttributedString else {
				assertionFailure("Could not cast mutableCopy to NSMutableAttributedString")
				return false
			}
			var attributedRange = NSRange(location: 0, length: 0)
			if attributedText.length > 0 {
				attributedText.attribute(NSForegroundColorAttributeName, at: 0, longestEffectiveRange: &attributedRange, in: NSRange(location: 0, length: attributedText.length))
			}
			var schoolName: String!
			if range.location <= attributedRange.location + attributedRange.length && range.length <= attributedRange.length {
				schoolName = (attributedText.string as NSString).substring(with: attributedRange)
			} else {
				schoolName = attributedText.string
			}
			schoolName = (schoolName as NSString).replacingCharacters(in: range, with: string)
			let suggestion = getSchoolSuggestion(schoolName)
			let attributedString = NSMutableAttributedString(string: suggestion)
			attributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor.gray, range: NSRange(location: schoolName.characters.count, length: suggestion.characters.count - schoolName.characters.count))
			textField.attributedText = attributedString
			textField.selectedTextRange = textField.textRange(from: textField.position(from: textField.beginningOfDocument, offset: range.location + string.characters.count)!, to: textField.position(from: textField.beginningOfDocument, offset: range.location + string.characters.count)!)
			return false
		}
		return true
	}

	func getSchoolSuggestion(_ schoolName: String) -> String {
		guard !schoolName.isEmpty else {
			return schoolName
		}
		var low = schools.startIndex
		var high = schools.endIndex
		var mid: Int
		while low < high {
			mid = low.advanced(by: low.distance(to: high) / 2)
			let name = schools[mid].name
			if ((name.lowercased().hasPrefix(schoolName.lowercased()))) {
				return name
			} else if name > schoolName {
				high = mid
			} else if name < schoolName {
				low = mid.advanced(by: 1)
			}
		}
		return schoolName
	}

	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		view.endEditing(true)
	}

	func keyboardWillChange(notification: NSNotification) {
		guard let userInfo = notification.userInfo,
			let animationDuration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue,
			let keyboardEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
				return
		}
		let convertedKeyboardEndFrame = view.convert(keyboardEndFrame, from: view.window)
		let rawAnimationCurve = (userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber)?.uintValue ?? 0
		let animationCurve = UIViewAnimationOptions(rawValue: rawAnimationCurve)
		loginScrollView.contentInset = UIEdgeInsets(top: loginScrollView.contentInset.top, left: loginScrollView.contentInset.left, bottom: view.bounds.maxY - convertedKeyboardEndFrame.minY, right: loginScrollView.contentInset.right)
		loginScrollView.scrollIndicatorInsets = UIEdgeInsets(top: loginScrollView.scrollIndicatorInsets.top, left: loginScrollView.scrollIndicatorInsets.left, bottom: view.bounds.maxY - convertedKeyboardEndFrame.minY, right: loginScrollView.scrollIndicatorInsets.right)
		loginViewHeightConstraint.constant = -view.bounds.maxY + convertedKeyboardEndFrame.minY
		UIView.animate(withDuration: animationDuration, delay: 0.0, options: [UIViewAnimationOptions.beginFromCurrentState, animationCurve], animations: {
			self.view.layoutIfNeeded()
		})
		if view.bounds.height + loginViewHeightConstraint.constant < loginScrollView.contentSize.height {
			loginScrollView.flashScrollIndicators()
		}
	}

	// MARK: - Navigation

	// In a storyboard-based application, you will often want to do a little preparation before navigation
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		// Get the new view controller using segue.destinationViewController.
		// Pass the selected object to the new view controller.
		view.endEditing(true)
	}

}

@IBDesignable extension UIButton {
	@IBInspectable var cornerRadius: CGFloat {
		get {
			return layer.cornerRadius
		}
		set {
			layer.cornerRadius = newValue
		}
	}
}
