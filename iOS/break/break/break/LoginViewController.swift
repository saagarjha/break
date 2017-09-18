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

	@IBOutlet weak var loginScrollView: UIScrollView! {
		didSet {
			loginScrollView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
		}
	}
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

	var movingAnimatableViews = [UIView]()
	var stationaryAnimatableViews = [UIView]()

	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent
	}

	var runAnimation = true

	override func viewDidLoad() {
		super.viewDidLoad()

		// Do any additional setup after loading the view.
		navigationController?.setNavigationBarHidden(true, animated: false)

		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange), name: .UIKeyboardWillShow, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange), name: .UIKeyboardWillHide, object: nil)

		schoolLoop = SchoolLoop.sharedInstance
		getSchools()

		movingAnimatableViews = [schoolNameTextField, usernameTextField, passwordTextField, logInButton]
		stationaryAnimatableViews = [breakStackView, forgotButton, privacyPolicyButton]
		(movingAnimatableViews + stationaryAnimatableViews).forEach {
			$0.alpha = 0
		}
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		if runAnimation {
			let dy = passwordTextField.frame.midY - schoolNameTextField.frame.midY
			movingAnimatableViews.forEach {
				$0.frame = $0.frame.offsetBy(dx: 0, dy: dy)
			}
			UIView.animate(withDuration: breakConstants.loginStationaryAnimationDuration, delay: 0, options: .curveEaseInOut, animations: { [unowned self] in
				self.stationaryAnimatableViews.forEach {
					$0.alpha = 1
				}
			}, completion: nil)
			for (delay, view) in zip(stride(from: 0, to: .infinity, by: breakConstants.loginMovableAnimationDelay), movingAnimatableViews) {
				UIView.animate(withDuration: breakConstants.loginMovableAnimationDuration, delay: delay, options: .curveEaseInOut, animations: {
					view.frame = view.frame.offsetBy(dx: 0, dy: -dy)
					view.alpha = 1
				}, completion: nil)
			}
		}
		schoolNameTextField.becomeFirstResponder()
		runAnimation = false
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	@IBAction func logIn(_ sender: Any) {
		UIApplication.shared.isNetworkActivityIndicatorVisible = true
		logInButton.isEnabled = false
		logInButton.alpha = 0.5
		schoolLoop.logIn(withSchoolName: schoolNameTextField.text ?? "", username: usernameTextField.text ?? "", password: passwordTextField.text ?? "") { error in
			DispatchQueue.main.async { [weak self] in
				guard let `self` = self else {
					return
				}
				UIApplication.shared.isNetworkActivityIndicatorVisible = false
				if error == .noError {
					(UIApplication.shared.delegate as? AppDelegate)?.saveCache()
					`self`.showLogin()
				} else if error == .networkError {
					let alertController = UIAlertController(title: "Network error", message: "There was an issue accessing School Loop. Please try again.", preferredStyle: .alert)
					let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
					alertController.addAction(okAction)
					`self`.present(alertController, animated: true, completion: nil)
				} else {
					let alertController = UIAlertController(title: "Authentication failed", message: "Please check your login credentials and try again.", preferredStyle: .alert)
					let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
					alertController.addAction(okAction)
					`self`.present(alertController, animated: true, completion: nil)
				}
				`self`.logInButton.isEnabled = true
				`self`.logInButton.alpha = 1
			}
		}
	}

	@IBAction func forgot(_ sender: Any) {
		let safariViewController = breakSafariViewController(url: SchoolLoopConstants.forgotURL, entersReaderIfAvailable: false)
		present(safariViewController, animated: true, completion: nil)
	}

	@IBAction func privacyPolicy(_ sender: Any) {
		let safariViewController = breakSafariViewController(url: URL(string: "https://saagarjha.com/projects/break/privacy-policy/")!, entersReaderIfAvailable: false)
		present(safariViewController, animated: true, completion: nil)
	}

	var loginTries = 0

	func getSchools() {
		UIApplication.shared.isNetworkActivityIndicatorVisible = true
		schoolLoop.getSchools { error in
			DispatchQueue.main.async { [unowned self] in
				if error == .noError {
					UIApplication.shared.isNetworkActivityIndicatorVisible = false
					self.schools = self.schoolLoop.schools
					self.schools.sort()
					self.loginTries = 0
				} else {
					if self.loginTries < 3 {
						self.loginTries += 1
						self.getSchools()
					} else {
						self.loginTries = 0
						let alertController = UIAlertController(title: "Failed to fetch schools", message: "We couldn't fetch a list of schools. Try checking your internet connection and trying again.", preferredStyle: .alert)
						let retryAction = UIAlertAction(title: "Retry", style: .default) { _ in
							self.getSchools()
						}
						alertController.addAction(retryAction)
						self.present(alertController, animated: true, completion: nil)
					}
				}
			}
		}
	}

	func showLogin() {
		// Create the main tab bar controller
		let storybard = UIStoryboard(name: "Main", bundle: nil)
		let tabBarController = storybard.instantiateViewController(withIdentifier: "tab")

		// Create a fade-in animation when logging in
		let oldView = UIScreen.main.snapshotView(afterScreenUpdates: false)
		tabBarController.view.addSubview(oldView)
		UIApplication.shared.keyWindow?.rootViewController = tabBarController
		UIView.animate(withDuration: 0.25, animations: {
			oldView.alpha = 0
		}, completion: { _ in
			oldView.removeFromSuperview()
		})

		// Force each view controller to load its view so that it is up-to-date
		var view: UIView?
		if let tabBarController = UIApplication.shared.delegate?.window??.rootViewController as? UITabBarController {
			for type in [CoursesViewController.self, AssignmentsViewController.self, LoopMailViewController.self, NewsViewController.self] {
				if let viewController = tabBarController.viewControllerOfType(type) {
					view = viewController.view
				}
			}
		}
		// Silence the unused variable warning
		if let _ = view {
			return
		}
	}

	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		if textField === schoolNameTextField {
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
		// "Confirm" the suggestion for the school name text field
		if textField === schoolNameTextField {
			textField.textColor = nil
		}
		// Fix a bug with the text "jumping" due to a keyboard animation
		textField.layoutIfNeeded()
	}

	func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
		guard textField === schoolNameTextField else {
			return true
		}
		guard let attributedText = textField.attributedText?.mutableCopy() as? NSMutableAttributedString else {
			assertionFailure("Could not cast mutableCopy to NSMutableAttributedString")
			return true
		}
		
		// Find the position of the user-entered text
		var attributedRange = NSRange(location: 0, length: 0)
		if attributedText.length > 0 {
			attributedText.attribute(.foregroundColor, at: 0, longestEffectiveRange: &attributedRange, in: NSRange(location: 0, length: attributedText.length))
		}
		
		// If the range specified is in the user-entered range, use that,
		// otherwise use the whole string
		var schoolName: String
		if range.location <= attributedRange.location + attributedRange.length && range.length <= attributedRange.length {
			schoolName = (attributedText.string as NSString).substring(with: attributedRange)
		} else {
			schoolName = attributedText.string
		}
		schoolName = (schoolName as NSString).replacingCharacters(in: range, with: string)
		let suggestion = getSchoolSuggestion(forSchoolName: schoolName)
		
		// Display the suggestion
		let attributedString = NSMutableAttributedString(string: suggestion)
		attributedString.addAttribute(.foregroundColor, value: UIColor.gray, range: NSRange(location: schoolName.characters.count, length: suggestion.characters.count - schoolName.characters.count))
		textField.attributedText = attributedString
		
		// On iOS, it appears that setting the string "scrolls" the text field
		// to the end. Setting the cursor location (as below) will work,
		// however, this is done in a "lazy" way so that minimum "scrolling" is
		// needed. If the text is long, the text field will first scroll to the
		// end and then scroll back so that the cursor is just barely on the
		// screen on the left side. If we force a scroll to the beginning by
		// moving the cursor to the start of the text, we can prevent this
		// undesirable behavior and make it appear as if no "scrolling" was
		// performed.
		
		// Move the cursor to the start
		textField.position(from: textField.beginningOfDocument, offset: 0).flatMap { textField.selectedTextRange = textField.textRange(from: $0, to: $0) }
		
		// Move the cursor to where it should be, in between the user's string
		// and the suggestion
		textField.position(from: textField.beginningOfDocument, offset: range.location + string.characters.count).flatMap { textField.selectedTextRange = textField.textRange(from: $0, to: $0) }
		return false

	}

	func getSchoolSuggestion(forSchoolName schoolName: String) -> String {
		// Do not return a suggestion if the school name is empty
		guard !schoolName.isEmpty else {
			return schoolName
		}
		// Binary search to find an appropriate suggestion
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

	@objc func hideKeyboard() {
		view.endEditing(true)
	}

	@objc func keyboardWillChange(notification: NSNotification) {
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
		UIView.animate(withDuration: animationDuration, delay: 0, options: [UIViewAnimationOptions.beginFromCurrentState, animationCurve], animations: {
			self.view.layoutIfNeeded()
		})
		// If scrolling is possible, flash the scroll indicators to show this
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
