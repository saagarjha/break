//
//  ViewModesViewController.swift
//  break
//
//  Created by Saagar Jha on 2/19/17.
//  Copyright © 2017 Saagar Jha. All rights reserved.
//

import UIKit

class ViewModesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

	static let cellIdentifier = "viewMode"

	var viewModeDelegate: ViewModeDelegate?

	var viewMode: ViewMode!

	var viewModesTableView: UITableView!

	override func viewDidLoad() {
		super.viewDidLoad()

		// Do any additional setup after loading the view.
		viewModesTableView = UITableView()
		viewModesTableView.dataSource = self
		viewModesTableView.delegate = self
		viewModesTableView.register(UITableViewCell.self, forCellReuseIdentifier: ViewModesViewController.cellIdentifier)
		view = viewModesTableView
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return ViewMode._count.rawValue
	}

	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return "View Mode"
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: ViewModesViewController.cellIdentifier, for: indexPath)
		if let viewMode = ViewMode(rawValue: indexPath.row) {
			cell.textLabel?.text = viewMode.description

			if viewMode == self.viewMode {
				cell.accessoryType = .checkmark
			}
		} else {
			assertionFailure("ViewMode row is out of bounds")
		}
		return cell
	}

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		guard let viewMode = ViewMode(rawValue: indexPath.row) else {
			assertionFailure("ViewMode row is out of bounds")
			return
		}
		viewModeDelegate?.changedMode(to: viewMode)
		dismiss(animated: false, completion: nil)
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
