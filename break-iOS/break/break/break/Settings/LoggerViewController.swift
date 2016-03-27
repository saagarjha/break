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

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	@IBAction func clear(sender: AnyObject) {
		Logger.clearLog()
		logTextView.text = Logger.readLog()
	}

	@IBAction func share(sender: AnyObject) {
		let activityViewController = UIActivityViewController(activityItems: [logTextView.text], applicationActivities: nil)
		presentViewController(activityViewController, animated: true, completion: nil)
	}

	@IBAction func mark(sender: AnyObject) {
		let alertController = UIAlertController(title: "Add a mark to the log", message: nil, preferredStyle: .Alert)
		alertController.addTextFieldWithConfigurationHandler() { textField in
			textField.placeholder = "Mark"
		}
		let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
		let doneAction = UIAlertAction(title: "Done", style: .Default) { action in
			Logger.log("[MARK] \(alertController.textFields!.first!.text!)")
			self.logTextView.text = Logger.readLog()
		}
		alertController.addAction(cancelAction)
		alertController.addAction(doneAction)
		presentViewController(alertController, animated: true, completion: nil)
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
