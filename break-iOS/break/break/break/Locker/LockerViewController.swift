//
//  LockerViewController.swift
//  break
//
//  Created by Saagar Jha on 2/26/16.
//  Copyright © 2016 Saagar Jha. All rights reserved.
//

import SafariServices
import UIKit

class LockerViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

	let cellIdentifier = "lockerItem"

	var path = "/"

	var schoolLoop: SchoolLoop!
	var lockerItems: [SchoolLoopLockerItem] = []

	var destinationViewController: LockerItemViewController!

	@IBOutlet weak var lockerCollectionView: UICollectionView! {
		didSet {
			lockerCollectionView.alwaysBounceVertical = true
			refreshControl.addTarget(self, action: #selector(LockerViewController.refresh(_:)), forControlEvents: .ValueChanged)
			lockerCollectionView.addSubview(refreshControl)
		}
	}
	let refreshControl = UIRefreshControl()

	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		// Do any additional setup after loading the view.
		schoolLoop = SchoolLoop.sharedInstance
		if path.componentsSeparatedByString("/").count < 3 {
			let items = ["My Courses", "My Locker"]
			let segmentedControl = UISegmentedControl(items: items)
			navigationItem.titleView = segmentedControl
			if items.indexOf(path.componentsSeparatedByString("/")[1]) == nil {
				schoolLoop.getLocker(path, completion: nil)
				segmentedControl.selectedSegmentIndex = 0
				path = path + items[0].stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())! + "/"
			}
			segmentedControl.addTarget(self, action: #selector(LockerViewController.changePath(_:)), forControlEvents: .ValueChanged)
		} else {
			navigationItem.leftItemsSupplementBackButton = true
			navigationItem.leftBarButtonItem = nil
		}
		refresh(self)
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	func refresh(sender: AnyObject) {
		schoolLoop.getLocker(path) { error in
			dispatch_async(dispatch_get_main_queue()) {
				if error == .NoError {
					guard let lockerItem = self.schoolLoop.lockerItemForPath(self.path) else {
						return
					}

					lockerItem.lockerItems.sortInPlace()
					self.lockerItems = lockerItem.lockerItems
					self.lockerCollectionView.reloadData()
				}
				self.refreshControl.performSelector(#selector(UIRefreshControl.endRefreshing), withObject: nil, afterDelay: 0)
			}
		}
	}

	@IBAction func openSettings(sender: AnyObject) {
		let viewController = UIStoryboard(name: "Settings", bundle: nil).instantiateViewControllerWithIdentifier("settings")
		navigationController?.presentViewController(viewController, animated: true, completion: nil)
	}

	func changePath(sender: UISegmentedControl) {
		path = "/" + sender.titleForSegmentAtIndex(sender.selectedSegmentIndex)!.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())! + "/"
		refresh(self)
	}

	func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
		return UIEdgeInsetsMake(0, 25, 0, 25)
	}

	func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
		return 1
	}

	func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return lockerItems.count
	}

	func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
		guard let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellIdentifier, forIndexPath: indexPath) as? LockerItemCollectionViewCell else {
			assertionFailure("Could not deque LockerItemCollectionViewCell")
			return collectionView.dequeueReusableCellWithReuseIdentifier(cellIdentifier, forIndexPath: indexPath)
		}
		cell.nameLabel.text = lockerItems[indexPath.row].name
		if lockerItems[indexPath.row].type == SchoolLoopLockerItemType.Directory {
			cell.typeImageView.image = UIImage(named: "FolderIcon")
		} else {
			cell.typeImageView.image = UIImage(named: "FileIcon")
		}
		return cell
	}

	func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
		let lockerItem = lockerItems[indexPath.row]
		if lockerItem.type != .Directory {
			destinationViewController.title = lockerItem.name
			destinationViewController.path = lockerItem.path
		} else {
			guard let newLockerViewController = navigationController?.storyboard?.instantiateViewControllerWithIdentifier("locker") as? LockerViewController else {
				assertionFailure("Could not open LockerViewController")
				return
			}
			newLockerViewController.path = lockerItem.path
			newLockerViewController.title = lockerItem.name
			navigationController?.pushViewController(newLockerViewController, animated: true)
		}
	}

	override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
		if lockerItems[lockerCollectionView.indexPathsForSelectedItems()![0].row].type == SchoolLoopLockerItemType.Directory {
			return false
		}
		return true
	}

	// MARK: - Navigation

	// In a storyboard-based application, you will often want to do a little preparation before navigation
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		// Get the new view controller using segue.destinationViewController.
		// Pass the selected object to the new view controller.
		guard let destinationViewController = segue.destinationViewController as? LockerItemViewController else {
			assertionFailure("Could not cast destinationViewController to LockerItemViewController")
			return
		}
		self.destinationViewController = destinationViewController
	}
}
