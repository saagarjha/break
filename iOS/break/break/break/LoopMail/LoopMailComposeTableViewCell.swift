//
//  LoopMailComposeTableViewCell.swift
//  break
//
//  Created by Saagar Jha on 11/14/16.
//  Copyright © 2016 Saagar Jha. All rights reserved.
//

import UIKit

class LoopMailComposeTableViewCell: UITableViewCell {
	
	var isContacts = false

	@IBOutlet weak var headerLabel: UILabel!
	@IBOutlet weak var headerTextField: UITextField! {
		didSet {
			headerTextField.isUserInteractionEnabled = false
			headerTextField.borderStyle = .none
		}
	}
	
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
