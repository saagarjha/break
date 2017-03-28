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

	let cellIdentifier = "compose"

	let leftQuoteInset: CGFloat = 20

	@IBOutlet weak var composeTableView: UITableView! {
		didSet {
			let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(LoopMailComposeViewController.selectMessageTextView(_:)))
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
			composeTextView.font = UIFont.systemFont(ofSize: 16)
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
			messageTextView.attributedText = try? NSAttributedString(data: (message.data(using: .utf8)) ?? Data(), options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType], documentAttributes: nil)
			messageTextView.textContainerInset = UIEdgeInsets(top: messageTextView.textContainerInset.top, left: leftQuoteInset, bottom: messageTextView.textContainerInset.bottom, right: messageTextView.textContainerInset.right)
			composeTextView.font = UIFont.systemFont(ofSize: messageTextView.font?.pointSize ?? 0)
		}
	}

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
			let dateFormatter = DateFormatter()
			dateFormatter.dateFormat = "MMM d, y @ HH:mm"
			message = "<meta name=\"viewport\" content=\"initial-scale=1.0\" /><style type=\"text/css\">body{font: -apple-system-body;}</style><h4><span style=\"font-weight:normal\"><p>On " + dateFormatter.string(from: loopMail?.date ?? .distantPast) + ", <b>\(loopMail?.sender.name ?? "")</b>  wrote:</p><blockquote>\(m)</blockquote>"
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
		
		NotificationCenter.default.addObserver(self, selector: #selector(LoopMailComposeViewController.keyboardWillChange(notification:)), name: .UIKeyboardWillShow, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(LoopMailComposeViewController.keyboardWillChange(notification:)), name: .UIKeyboardWillHide, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(LoopMailComposeViewController.deviceOrientationDidChange(notification:)), name: .UIDeviceOrientationDidChange, object: nil)

		addComposeView()
		drawBorders()

		schoolLoop = SchoolLoop.sharedInstance
	}

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		composeTextView.becomeFirstResponder()
	}

	func addComposeView() {
		composeView.addSubview(composeTextView)
		composeView.addSubview(messageTextView)
		let views: [String: Any] = ["compose": composeTextView, "message": messageTextView]
		var constraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-[compose][message]-|", options: [], metrics: nil, views: views)
		constraints += NSLayoutConstraint.constraints(withVisualFormat: "|[compose]|", options: [], metrics: nil, views: views)
		constraints += NSLayoutConstraint.constraints(withVisualFormat: "|[message]|", options: [], metrics: nil, views: views)
		NSLayoutConstraint.activate(constraints)
		if message == nil {
			messageTextView.removeFromSuperview()
		}
		composeView.setNeedsLayout()
		composeView.layoutIfNeeded()
		composeView.frame = CGRect(origin: composeView.frame.origin, size: composeView.systemLayoutSizeFitting(UILayoutFittingCompressedSize))
		composeTableView.tableFooterView = composeView
	}

	func drawBorders() {
		let topBorder: CALayer = CALayer()
		topBorder.frame = CGRect(x: 0, y: 0, width: composeTextView.frame.width, height: 1 / UIScreen.main.scale)
		topBorder.backgroundColor = composeTableView.separatorColor?.cgColor
		composeView.layer.addSublayer(topBorder)

		messageTextView.textColor = .gray
		messageTextView.sizeToFit()

		let leftBorder: CALayer = CALayer()
		leftBorder.frame = CGRect(x: leftQuoteInset / 2, y: 0, width: 1 / UIScreen.main.scale, height: messageTextView.contentSize.height)
		leftBorder.backgroundColor = UIColor.gray.cgColor
		messageTextView.layer.addSublayer(leftBorder)
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	@IBAction func send(_ sender: Any) {
		schoolLoop.sendLoopMail(withComposedLoopMail: SchoolLoopComposedLoopMail(subject: subjectTextField.text ?? "", message: "<p>\(composeTextView.text ?? "")</p>\n\n\n\(message ?? "")", to: Array(to), cc: Array(cc))) { error in
			DispatchQueue.main.async {
				self.navigationController?.popViewController(animated: true)
			}
		}
	}

	func selectMessageTextView(_ sender: UITapGestureRecognizer) {
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
		guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? LoopMailComposeTableViewCell else {
			assertionFailure("Could not deque LoopMailComposeTableViewCell")
			return tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
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
		textView.frame = CGRect(origin: textView.frame.origin, size: CGSize(width: textView.frame.width, height: textView.sizeThatFits(CGSize(width: textView.frame.width, height: .greatestFiniteMagnitude)).height))
		composeTableView.tableFooterView = textView
	}

	func keyboardWillChange(notification: NSNotification) {
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
		UIView.animate(withDuration: animationDuration, delay: 0.0, options: [UIViewAnimationOptions.beginFromCurrentState, animationCurve], animations: {
			self.composeTableView.layoutIfNeeded()
		})
		composeTableView.tableFooterView = composeTableView.tableFooterView
	}

	func deviceOrientationDidChange(notification: NSNotification) {
		drawBorders()
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
