//
//  LoopMailComposeViewController.swift
//  break
//
//  Created by Saagar Jha on 11/14/16.
//  Copyright © 2016 Saagar Jha. All rights reserved.
//

import UIKit
import WebKit

class LoopMailComposeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate, WKNavigationDelegate {

	static let cellIdentifier = "compose"

	static let leftQuoteInset: CGFloat = 20

	static let dateFormatter: DateFormatter = {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "MMM d, y @ HH:mm"
		return dateFormatter
	}()

	@IBOutlet weak var composeTableView: UITableView! {
		didSet {
			let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectMessageTextView))
			gestureRecognizer.cancelsTouchesInView = false
			composeTableView.addGestureRecognizer(gestureRecognizer)
		}
	}
	var subjectTextField: UITextField!
	let composeView = UIView(frame: UIScreen.main.bounds)
	var composeTextView: UITextView! {
		didSet {
			composeTextView.translatesAutoresizingMaskIntoConstraints = false
			composeTextView.isScrollEnabled = false
			composeTextView.font = UIFont.preferredFont(forTextStyle: .body)
			composeTextView.delegate = self
		}
	}
	var messageTextView: UITextView! {
		didSet {
			messageTextView.translatesAutoresizingMaskIntoConstraints = false
			messageTextView.isScrollEnabled = false
			messageTextView.isEditable = false

			guard let message = message else {
				return
			}
			messageTextView.attributedText = try? NSAttributedString(data: Data(message.utf8), options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil)
			messageTextView.textColor = .gray

			messageTextView.textContainerInset = UIEdgeInsets(top: messageTextView.textContainerInset.top, left: LoopMailComposeViewController.leftQuoteInset, bottom: messageTextView.textContainerInset.bottom, right: messageTextView.textContainerInset.right)
		}
	}
	let topBorder = CALayer()
	let leftBorder = CALayer()

	var schoolLoop: SchoolLoop!
	var loopMail: SchoolLoopLoopMail?
	var composedLoopMail: SchoolLoopComposedLoopMail? {
		didSet {
			to = Set<SchoolLoopContact>(composedLoopMail?.to ?? [])
			cc = Set<SchoolLoopContact>(composedLoopMail?.cc ?? [])
			guard var s = composedLoopMail?.subject else {
				return
			}
			if !s.hasPrefix("Re: ") {
				s = "Re: \(s)"
			}
			subject = s
			guard let m = composedLoopMail?.message else {
				return
			}
			// There seems to be a bug with string interpolation here
			message = breakConstants.webViewDefaultStyle + "<h4><span style=\"font-weight:normal\"><p>On " + LoopMailComposeViewController.dateFormatter.string(from: loopMail?.date ?? .distantPast) + ", <b>\(loopMail?.sender.name ?? "")</b>  wrote:</p><blockquote>\(m)</blockquote>"
		}
	}
	var contactHeader: Int?
	var subject: String?
	var message: String?
	var to = Set<SchoolLoopContact>()
	var cc = Set<SchoolLoopContact>()

	override func viewDidLoad() {
		super.viewDidLoad()

		// Do any additional setup after loading the view.
		composeTextView = UITextView()
		messageTextView = UITextView()

		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange), name: .UIKeyboardWillShow, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange), name: .UIKeyboardWillHide, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(deviceOrientationDidChange), name: .UIDeviceOrientationDidChange, object: nil)

		schoolLoop = SchoolLoop.sharedInstance
	}

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		addComposeView()
		drawBorders()
		composeTextView.becomeFirstResponder()
	}

	func addComposeView() {
		composeView.addSubview(composeTextView)
		composeView.addSubview(messageTextView)
		let views: [String: Any] = ["compose": composeTextView, "message": messageTextView]
		var constraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|[compose][message]|", options: [], metrics: nil, views: views)
		constraints += NSLayoutConstraint.constraints(withVisualFormat: "|[compose]|", options: [], metrics: nil, views: views)
		constraints += NSLayoutConstraint.constraints(withVisualFormat: "|[message]|", options: [], metrics: nil, views: views)
		NSLayoutConstraint.activate(constraints)
		if message == nil {
			messageTextView.removeFromSuperview()
		}
		relayoutComposeView()
	}

	func relayoutComposeView() {
		// Calculate the size of the compose view
		let preferredSize = CGSize(width: composeTableView.frame.width, height: .infinity)
		composeView.frame.size.height = composeTextView.sizeThatFits(preferredSize).height + messageTextView.sizeThatFits(preferredSize).height

		// Let the table view know about the new size
		composeTableView.tableFooterView = composeView
	}

	func drawBorders() {
		topBorder.frame.origin = .zero
		topBorder.frame.size.height = 1 / UIScreen.main.scale
		topBorder.backgroundColor = composeTableView.separatorColor?.cgColor
		composeView.layer.addSublayer(topBorder)

		leftBorder.frame.origin = CGPoint(x: LoopMailComposeViewController.leftQuoteInset / 2, y: 0)
		leftBorder.frame.size.width = 1 / UIScreen.main.scale
		leftBorder.backgroundColor = UIColor.gray.cgColor
		messageTextView.layer.addSublayer(leftBorder)

		resizeBorders()
	}

	func resizeBorders() {
		composeView.layoutIfNeeded()
		topBorder.frame.size.width = composeView.frame.width

		messageTextView.layoutIfNeeded()
		leftBorder.frame.size.height = messageTextView.frame.height
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	@IBAction func cancel(_ sender: Any) {
		navigationController?.dismiss(animated: true, completion: nil)
	}

	@IBAction func send(_ sender: Any) {
		schoolLoop.sendLoopMail(with: SchoolLoopComposedLoopMail(subject: subjectTextField.text ?? "", message: "<p>\(composeTextView.text ?? "")</p>\n\n\n\(message ?? "")", to: Array(to), cc: Array(cc))) { error in
			DispatchQueue.main.async { [weak self] in
				guard let `self` = self else {
					return
				}
				`self`.navigationController?.popViewController(animated: true)
			}
		}
	}

	@objc func selectMessageTextView(_ sender: UITapGestureRecognizer) {
		// If the user touches "below" the compose text view (only possible if
		// the tableview doesn't fill the screen), then act as if the text view
		// fills the screen and give it first responder status
		if sender.location(in: composeTextView).y > 0 {
			composeTextView.becomeFirstResponder()
		}
	}

	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 3
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: LoopMailComposeViewController.cellIdentifier, for: indexPath) as? LoopMailComposeTableViewCell else {
			assertionFailure("Could not deque LoopMailComposeTableViewCell")
			return tableView.dequeueReusableCell(withIdentifier: LoopMailComposeViewController.cellIdentifier, for: indexPath)
		}
		switch indexPath.row {
		case 0:
			cell.headerLabel.text = "Subject:"
			if let subject = self.subject {
				cell.headerTextField.text = subject
				self.subject = nil
			}
			cell.headerTextField.isUserInteractionEnabled = true
			subjectTextField = cell.headerTextField
		case 1:
			cell.headerLabel.text = "To:"
			cell.isContacts = true
			cell.headerTextField.text = Array(to.map({ $0.name })).joined(separator: ", ")
		case 2:
			cell.headerLabel.text = "CC:"
			cell.isContacts = true
			cell.headerTextField.text = Array(cc.map({ $0.name })).joined(separator: ", ")
		default:
			break
		}
		cell.selectionStyle = .none
		return cell
	}

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		switch indexPath.row {
		case 0:
			subjectTextField.becomeFirstResponder()
		case 1:
			fallthrough
		case 2:
			contactHeader = indexPath.row
			let storybard = UIStoryboard(name: "Main", bundle: nil)
			let contactsViewController = storybard.instantiateViewController(withIdentifier: "loopMailContacts")
			if let contactsViewController = contactsViewController as? LoopMailContactsViewController {
				contactsViewController.loopMailContactsDelegate = self
				if contactHeader == 1 {
					contactsViewController.selectedContacts = Array(to)
				} else if contactHeader == 2 {
					contactsViewController.selectedContacts = Array(cc)
				}
			}
			navigationController?.pushViewController(contactsViewController, animated: true)
		default:
			break
		}
		tableView.deselectRow(at: indexPath, animated: false)
	}

	func textViewDidChange(_ textView: UITextView) {
		// Text changes invalidate the size, requiring a relayout
		relayoutComposeView()
	}

	@objc func keyboardWillChange(notification: NSNotification) {
		guard let userInfo = notification.userInfo,
			let animationDuration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue,
			let keyboardEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
				return
		}
		let convertedKeyboardEndFrame = composeTableView.convert(keyboardEndFrame, from: composeTableView.window)
		let rawAnimationCurve = (userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber)?.uintValue ?? 0
		let animationCurve = UIViewAnimationOptions(rawValue: rawAnimationCurve)
		composeTableView.contentInset = UIEdgeInsets(top: composeTableView.contentInset.top, left: composeTableView.contentInset.left, bottom: max(composeTableView.bounds.maxY - convertedKeyboardEndFrame.minY, tabBarController?.tabBar.frame.height ?? 0), right: composeTableView.contentInset.right)
		composeTableView.scrollIndicatorInsets = UIEdgeInsets(top: composeTableView.scrollIndicatorInsets.top, left: composeTableView.scrollIndicatorInsets.left, bottom: max(composeTableView.bounds.maxY - convertedKeyboardEndFrame.minY, tabBarController?.tabBar.frame.height ?? 0), right: composeTableView.scrollIndicatorInsets.right)
		composeTableView.flashScrollIndicators()
		UIView.animate(withDuration: animationDuration, delay: 0, options: [UIViewAnimationOptions.beginFromCurrentState, animationCurve], animations: {
				self.composeTableView.layoutIfNeeded()
			})
	}

	@objc func deviceOrientationDidChange(notification: NSNotification) {
		resizeBorders()
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

protocol LoopMailContactsDelegate {
	func selected(contacts: [SchoolLoopContact])
}

extension LoopMailComposeViewController: LoopMailContactsDelegate {
	func selected(contacts: [SchoolLoopContact]) {
		switch contactHeader ?? 0 {
		case 1:
			to = Set(contacts)
		case 2:
			cc = Set(contacts)
		default:
			return
		}
		DispatchQueue.main.async {
			self.composeTableView.reloadData()
		}
	}
}
