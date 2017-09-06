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
		setupSelfAsDetailViewController()
		
		logTextView.text = Logger.readLog()
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		guard logTextView.text.characters.count > 0 else {
			return
		}
		logTextView.layoutIfNeeded()
		logTextView.contentOffset = CGPoint(x: 0, y: logTextView.contentSize.height)
		logTextView.flashScrollIndicators()
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	@IBAction func clear(_ sender: Any) {
		Logger.clearLog()
		logTextView.text = Logger.readLog()
	}

	@IBAction func share(_ sender: Any) {
		let activityViewController = UIActivityViewController(activityItems: [logTextView.text], applicationActivities: nil)
		present(activityViewController, animated: true, completion: nil)
	}

	@IBAction func mark(_ sender: Any) {
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
	 override func prepareForSegue(segue: UIStoryboardSegue, sender: Any?) {
	 // Get the new view controller using segue.destinationViewController.
	 // Pass the selected object to the new view controller.
	 }
	 */
}
