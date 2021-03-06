//
//  LoopMailContactsViewController.swift
//  break
//
//  Created by Saagar Jha on 11/14/16.
//  Copyright © 2016 Saagar Jha. All rights reserved.
//

import UIKit

class LoopMailContactsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchResultsUpdating, KeyboardHandler {

	static let cellIdentifier = "contact"

	var loopMailContactsDelegate: LoopMailContactsDelegate?

	var schoolLoop: SchoolLoop!
	var contacts = [SchoolLoopContact]()
	var selectedContacts = [SchoolLoopContact]()

	@IBOutlet weak var contactsTableView: UITableView!
	let searchController = UISearchController(searchResultsController: nil)

	override func viewDidLoad() {
		super.viewDidLoad()

		// Do any additional setup after loading the view.
		addSearchBar(from: searchController, to: contactsTableView)
		if #available(iOS 11.0, *) {
			navigationItem.hidesSearchBarWhenScrolling = false
		}

		setupDefaultKeyboardHandler()

		navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
		schoolLoop = SchoolLoop.sharedInstance
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		// Wait for the search controller to finish its setup
		DispatchQueue.main.async {
			self.searchController.searchBar.becomeFirstResponder()
		}
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	@objc func done(_ sender: Any?) {
		loopMailContactsDelegate?.selected(contacts: selectedContacts)
		navigationController?.popViewController(animated: true)
	}

	func numberOfSections(in tableView: UITableView) -> Int {
		return 2
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch section {
		case 0:
			return selectedContacts.count
		case 1:
			return contacts.count
		default:
			return 0
		}
	}

	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		switch section {
		case 0:
			return "Selected"
		case 1:
			return "Search Results"
		default:
			return ""
		}
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: LoopMailContactsViewController.cellIdentifier, for: indexPath)
		let contact: SchoolLoopContact
		switch indexPath.section {
		case 0:
			contact = selectedContacts[indexPath.row]
			cell.accessoryType = .checkmark
		case 1:
			contact = contacts[indexPath.row]
			cell.accessoryType = .none
		default:
			return cell
		}
		cell.textLabel?.text = contact.name
		cell.detailTextLabel?.text = "\(contact.role)\(contact.desc)"
		return cell
	}

	func updateSearchResults(for searchController: UISearchController) {
		let filter = searchController.searchBar.text?.lowercased() ?? ""
		if !filter.isEmpty {
			schoolLoop.getLoopMailContacts(withQuery: filter) { contacts, error in
				guard error == .noError else {
					return
				}
				DispatchQueue.main.async { [weak self] in
					guard let `self` = self else {
						return
					}
					`self`.contacts = contacts.filter {
						!self.selectedContacts.contains($0)
					}
					`self`.contactsTableView.reloadData()
				}
			}
		} else {
			contacts.removeAll()
			contactsTableView.reloadData()
		}
	}

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		switch indexPath.section {
		case 0:
			contacts.append(selectedContacts.remove(at: indexPath.row))
		case 1:
			selectedContacts.append(contacts.remove(at: indexPath.row))
		default:
			return
		}
		tableView.deselectRow(at: indexPath, animated: true)
		contactsTableView.reloadData()
	}

	func keyboardUpdated(to keyboardEndFrame: CGRect) -> UIView {
		contactsTableView.contentInset = UIEdgeInsets(top: contactsTableView.contentInset.top, left: contactsTableView.contentInset.left, bottom: contactsTableView.frame.maxY - keyboardEndFrame.minY, right: contactsTableView.contentInset.right)
		contactsTableView.scrollIndicatorInsets = UIEdgeInsets(top: contactsTableView.scrollIndicatorInsets.top, left: contactsTableView.scrollIndicatorInsets.left, bottom: contactsTableView.frame.maxY - keyboardEndFrame.minY, right: contactsTableView.scrollIndicatorInsets.right)
		contactsTableView.flashScrollIndicators()
		return contactsTableView
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
