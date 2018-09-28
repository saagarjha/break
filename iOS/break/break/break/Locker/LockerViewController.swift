//
//  LockerViewController.swift
//  break
//
//  Created by Saagar Jha on 2/26/16.
//  Copyright © 2016 Saagar Jha. All rights reserved.
//

import MobileCoreServices
import SafariServices
import UIKit

class LockerViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIViewControllerPreviewingDelegate, UIDocumentInteractionControllerDelegate {

	static let cellIdentifier = "lockerItem"

	static let cellWidth: CGFloat = 144
	static let otherCellHeight: CGFloat = 128 + 8

	var path = "/"

	var schoolLoop: SchoolLoop!
	var lockerItems = [SchoolLoopLockerItem]()

	@IBOutlet weak var lockerCollectionView: UICollectionView! {
		didSet {
			lockerCollectionView.alwaysBounceVertical = true
			breakShared.add(refreshControl, to: lockerCollectionView)
			refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
			lockerCollectionViewFlowLayout?.estimatedItemSize = CGSize(width: LockerViewController.cellWidth, height: LockerViewController.cellWidth)
		}
	}
	var lockerCollectionViewFlowLayout: UICollectionViewFlowLayout? {
		get {
			return lockerCollectionView?.collectionViewLayout as? UICollectionViewFlowLayout
		}
	}
	let refreshControl = UIRefreshControl()

	override func viewDidLoad() {
		super.viewDidLoad()

		// Do any additional setup after loading the view.
		schoolLoop = SchoolLoop.sharedInstance
		if path.components(separatedBy: "/").count < 3 {
			let items = ["My Courses", "My Locker"]
			let segmentedControl = UISegmentedControl(items: items)
			navigationItem.titleView = segmentedControl
			if items.index(of: path.components(separatedBy: "/")[1]) == nil {
				schoolLoop.getLocker(withPath: path, completion: nil)
				segmentedControl.selectedSegmentIndex = 0
				if #available(iOS 11.0, *) {
					navigationItem.largeTitleDisplayMode = .always
				}
				path = path + items[0].addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)! + "/"
			}
			segmentedControl.addTarget(self, action: #selector(changePath), for: .valueChanged)
		} else {
			navigationItem.leftItemsSupplementBackButton = true
			navigationItem.leftBarButtonItem = nil
			if #available(iOS 11.0, *) {
				navigationItem.largeTitleDisplayMode = .never
			}
		}
		refresh(self)
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		lockerItems = SchoolLoop.sharedInstance.lockerItem(forPath: path)?.lockerItems ?? []
		lockerCollectionView.reloadData()
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	@objc func refresh(_ sender: Any) {
		UIApplication.shared.isNetworkActivityIndicatorVisible = true
		schoolLoop.getLocker(withPath: path) { error in
			DispatchQueue.main.async { [weak self] in
				guard let `self` = self else {
					return
				}
				UIApplication.shared.isNetworkActivityIndicatorVisible = false
				if error == .noError {
					guard let lockerItem = `self`.schoolLoop.lockerItem(forPath: `self`.path) else {
						return
					}
					lockerItem.lockerItems.sort()
					`self`.lockerItems = lockerItem.lockerItems
					`self`.lockerCollectionView.reloadData()
					`self`.lockerCollectionViewFlowLayout?.invalidateLayout()
				} else if error == .authenticationError {
					let alertController = UIAlertController(title: "Authentication error", message: "It looks like School Loop's locker doesn't work with your account. Please file a bug report with School Loop.", preferredStyle: .alert)
					let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
					alertController.addAction(okAction)
					`self`.present(alertController, animated: true, completion: nil)
				}
				// Otherwise the refresh control dismiss animation doesn't work
				`self`.refreshControl.perform(#selector(UIRefreshControl.endRefreshing), with: nil, afterDelay: 0)
			}
		}
	}

	@IBAction func openSettings(_ sender: Any) {
		let viewController = UIStoryboard(name: "Settings", bundle: nil).instantiateViewController(withIdentifier: "settings")
		navigationController?.present(viewController, animated: true, completion: nil)
	}

	@objc func changePath(_ sender: UISegmentedControl) {
		navigationItem.title = sender.titleForSegment(at: sender.selectedSegmentIndex) ?? ""
		path = "/" + (sender.titleForSegment(at: sender.selectedSegmentIndex) ?? "").addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)! + "/"
		refresh(self)
	}

	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
		let width: CGFloat
		if #available(iOS 11.0, *) {
			// In iOS 11 this method gets called slightly before rotating is
			// registered, so during the landscape -> portrait tranistion the
			// width ends up being incorrect. Exit early in this case and just
			// return whatever the safe area insets are.
			guard lockerCollectionView.safeAreaInsets.left == 0, lockerCollectionView.safeAreaInsets.right == 0 else {
				return lockerCollectionView.safeAreaInsets
			}

			width = lockerCollectionView.frame.width - lockerCollectionView.safeAreaInsets.right - lockerCollectionView.safeAreaInsets.left
		} else {
			width = lockerCollectionView.frame.width
		}
		// Do not use ceil here
		let inset = width.truncatingRemainder(dividingBy: LockerViewController.cellWidth) / (floor(width / LockerViewController.cellWidth) + 1)
		if #available(iOS 11.0, *) {
			return UIEdgeInsets(top: inset, left: lockerCollectionView.safeAreaInsets.left + inset, bottom: inset, right: lockerCollectionView.safeAreaInsets.right + inset)
		} else {
			return UIEdgeInsets(inset: inset)
		}
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		let width: CGFloat
		if #available(iOS 11.0, *) {
			width = lockerCollectionView.frame.width - lockerCollectionView.safeAreaInsets.right - lockerCollectionView.safeAreaInsets.left
		} else {
			width = lockerCollectionView.frame.width
		}
		let rowSize = Int(width / LockerViewController.cellWidth)
		let startIndex = indexPath.row / rowSize
		let maxTextHeight = (startIndex..<min(lockerItems.endIndex, startIndex + rowSize)).map { index in
			(lockerItems[index].name as NSString).boundingRect(with: CGSize(width: LockerViewController.cellWidth, height: .infinity), options: .usesLineFragmentOrigin, attributes: [.font: UIFont.preferredFont(forTextStyle: .headline)], context: nil).height
			}.max() ?? 0
		return CGSize(width: LockerViewController.cellWidth, height: LockerViewController.otherCellHeight + maxTextHeight)
	}

	func numberOfSections(in collectionView: UICollectionView) -> Int {
		return 1
	}

	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return lockerItems.count
	}

	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LockerViewController.cellIdentifier, for: indexPath) as? LockerItemCollectionViewCell else {
			assertionFailure("Could not deque LockerItemCollectionViewCell")
			return collectionView.dequeueReusableCell(withReuseIdentifier: LockerViewController.cellIdentifier, for: indexPath)
		}
		let lockerItem = lockerItems[indexPath.row]
		cell.nameLabel.text = lockerItem.name
		cell.typeImageView.image = LockerViewController.lockerItemImage(for: lockerItem)
		return cell
	}

	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		let lockerItem = lockerItems[indexPath.row]
		if lockerItem.type != .directory {
			presentLockerItemViewController(withLockerItem: lockerItem)
		} else {
			guard let newLockerViewController = navigationController?.storyboard?.instantiateViewController(withIdentifier: "locker") as? LockerViewController else {
				assertionFailure("Could not open LockerViewController")
				return
			}
			newLockerViewController.path = lockerItem.path
			newLockerViewController.title = lockerItem.name
			// If we're at the top level, grab the title from the segmented
			// control and set the back button's text
			if let segmentedControl = navigationItem.titleView as? UISegmentedControl {
				navigationItem.backBarButtonItem = UIBarButtonItem(title: segmentedControl.titleForSegment(at: segmentedControl.selectedSegmentIndex), style: .plain, target: nil, action: nil)
			}
			navigationController?.pushViewController(newLockerViewController, animated: true)
		}
	}

	func presentLockerItemViewController(withLockerItem lockerItem: SchoolLoopLockerItem) {
		UIApplication.shared.isNetworkActivityIndicatorVisible = true
		let file = schoolLoop.file(for: lockerItem)
		UIApplication.shared.isNetworkActivityIndicatorVisible = false
		let documentInteractionController = UIDocumentInteractionController(url: file)
		documentInteractionController.delegate = self
		documentInteractionController.presentPreview(animated: true)
	}

	func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
		return self
	}

	func documentInteractionControllerDidEndPreview(_ controller: UIDocumentInteractionController) {
		guard let url = controller.url else {
			return
		}
		try? FileManager.default.removeItem(at: url)
	}

	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
		super.viewWillTransition(to: size, with: coordinator)
		coordinator.animate(alongsideTransition: { [unowned self] _ in
			self.lockerCollectionView?.collectionViewLayout.invalidateLayout()
		}, completion: nil)
	}

	static func lockerItemImage(for lockerItem: SchoolLoopLockerItem) -> UIImage {
		switch lockerItem.type {
		case .directory:
			return #imageLiteral(resourceName: "FolderIcon")
		case .pdf:
			return #imageLiteral(resourceName: "PDFFileIcon")
		case .txt:
			return #imageLiteral(resourceName: "TXTFileIcon")
		case .doc:
			return #imageLiteral(resourceName: "DOCFileIcon")
		case .xls:
			return #imageLiteral(resourceName: "XLSFileIcon")
		case .ppt:
			return #imageLiteral(resourceName: "PPTFileIcon")
		case .pages:
			return #imageLiteral(resourceName: "PAGESFileIcon")
		case .numbers:
			return #imageLiteral(resourceName: "NUMBERSFileIcon")
		case .key:
			return #imageLiteral(resourceName: "KEYFileIcon")
		case .unknown:
			return #imageLiteral(resourceName: "FileIcon")
		}
	}

	// MARK: - Navigation

	override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
		if lockerItems[lockerCollectionView.indexPathsForSelectedItems![0].row].type == SchoolLoopLockerItemType.directory {
			return false
		}
		return false
	}

	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		setupForceTouch(originatingFrom: lockerCollectionView)
	}

	func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
		guard let indexPath = lockerCollectionView.indexPathForItem(at: location),
			let cell = lockerCollectionView.cellForItem(at: indexPath) else {
				return nil
		}
		guard let destinationViewController = storyboard?.instantiateViewController(withIdentifier: "locker") as? LockerViewController else {
			return nil
		}
		let selectedItem = lockerItems[indexPath.row]
		guard selectedItem.type == .directory else {
			return nil
		}
		destinationViewController.title = selectedItem.name
		destinationViewController.path = selectedItem.path
		destinationViewController.preferredContentSize = .zero
		previewingContext.sourceRect = cell.frame
		return destinationViewController
	}

	func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
		navigationController?.pushViewController(viewControllerToCommit, animated: true)
	}

	/*
	// In a storyboard-based application, you will often want to do a little preparation before navigation
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		// Get the new view controller using segue.destinationViewController.
		// Pass the selected object to the new view controller.
	}
	*/
}

extension UIEdgeInsets {
	init(inset: CGFloat) {
		self.init(top: inset, left: inset, bottom: inset, right: inset)
	}
}
