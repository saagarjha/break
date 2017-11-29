//
//  breakSafariViewController.swift
//  break
//
//  Created by Saagar Jha on 4/29/17.
//  Copyright © 2017 Saagar Jha. All rights reserved.
//

import SafariServices
import UIKit

class breakSafariViewController: SFSafariViewController {
	override init(url URL: URL, entersReaderIfAvailable: Bool) {
		super.init(url: URL, entersReaderIfAvailable: true)
		if #available(iOS 10.0, *) {
			preferredBarTintColor = UIColor.break
			preferredControlTintColor = .white
		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		// Do any additional setup after loading the view.
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
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
