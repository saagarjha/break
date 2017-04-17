//
//  LoggerViewController.swift
//  break
//
//  Created by Saagar Jha on 3/25/16.
//  Copyright © 2016 Saagar Jha. All rights reserved.
//

import UIKit

class LoggerViewController: UIViewController {
	@IBOutlet weak var logTextView: UITextView!

	override func viewDidLoad() {
		super.viewDidLoad()

		// Do any additional setup after loading the view.
		logTextView.text = Logger.readLog()
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		
		guard logTextView.text.characters.count > 0 else {
			return
		}
		UIView.setAnimationsEnabled(false)
		logTextView.scrollRangeToVisible(NSRange(location: logTextView.text.characters.count, length: 0))
		UIView.setAnimationsEnabled(true)
		logTextView.flashScrollIndicators()
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	@IBAction func clear(_ sender: AnyObject) {
		Logger.clearLog()
		logTextView.text = Logger.readLog()
	}

	@IBAction func share(_ sender: AnyObject) {
		let activityViewController = UIActivityViewController(activityItems: [logTextView.text], applicationActivities: nil)
		present(activityViewController, animated: true, completion: nil)
	}

	@IBAction func mark(_ sender: AnyObject) {
		let alertController = UIAlertController(title: "Add a mark to the log", message: nil, preferredStyle: .alert)
		alertController.addTextField { textField in
			textField.placeholder = "Mark"
		}
		let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
		let doneAction = UIAlertAction(title: "Done", style: .default) { action in
			self.logTextView.text = Logger.readLog()
		}
		alertController.addAction(cancelAction)
		alertController.addAction(doneAction)
		present(alertController, animated: true, completion: nil)
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
