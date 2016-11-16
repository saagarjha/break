//
//  LoopMailComposeViewController.swift
//  break
//
//  Created by Saagar Jha on 11/14/16.
//  Copyright © 2016 Saagar Jha. All rights reserved.
//

import UIKit

class LoopMailComposeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate {
	
	let cellIdentifier = "compose"

	@IBOutlet weak var composeTableView: UITableView!
	var subjectTextField: UITextField!
	@IBOutlet weak var composeTextView: UITextView! {
		didSet {
			composeTextView.isScrollEnabled = false
			composeTextView.delegate = self
			composeTextView.text = message
		}
	}
	@IBOutlet weak var bottomLayoutConstraint: NSLayoutConstraint!
	
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
			dateFormatter.dateFormat = "MMM d, yyyy @ HH:mm"
			message = "<p>\n<!-- Type right after this line -->\n\n\n<!-- Ignore everything below this line -->\n</p>\n\n\n<p>On " + dateFormatter.string(from: loopMail?.date ?? .distantPast) + ", <b>\(loopMail?.sender.name ?? "")</b>  wrote:</p><blockquote>\(m)</blockquote>"
		}
	}
	var contactHeader: Int?
	var subject: String?
	var message: String?
	var to: Set<SchoolLoopContact> = []
	var cc: Set<SchoolLoopContact> = []
	
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		NotificationCenter.default.addObserver(self, selector: #selector(LoopMailComposeViewController.keyboardWillChange(notification:)), name: .UIKeyboardWillShow, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(LoopMailComposeViewController.keyboardWillChange(notification:)), name: .UIKeyboardWillHide, object: nil)
		schoolLoop = SchoolLoop.sharedInstance
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	@IBAction func send(_ sender: Any) {
		schoolLoop.sendLoopMail(withComposedLoopMail: SchoolLoopComposedLoopMail(subject: subjectTextField.text ?? "", message: composeTextView.text, to: Array(to), cc: Array(cc))) { error in
			DispatchQueue.main.async {
				_ = self.navigationController?.popViewController(animated: true)
			}
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
		let rawAnimationCurve = ((userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber)?.uint32Value ?? 0) << 16
		let animationCurve = UIViewAnimationOptions(rawValue: UInt(rawAnimationCurve))
		bottomLayoutConstraint.constant = composeTableView.bounds.maxY - convertedKeyboardEndFrame.minY
		UIView.animate(withDuration: animationDuration, delay: 0.0, options: [UIViewAnimationOptions.beginFromCurrentState, animationCurve], animations: {
			self.composeTableView.layoutIfNeeded()
		})
		composeTableView.tableFooterView = composeTableView.tableFooterView
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
