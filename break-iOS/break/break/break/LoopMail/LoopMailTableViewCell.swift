//
//  LoopMailTableViewCell.swift
//  break
//
//  Created by Saagar Jha on 1/22/16.
//  Copyright © 2016 Saagar Jha. All rights reserved.
//

import UIKit

class LoopMailTableViewCell: UITableViewCell {

	@IBOutlet weak var subjectLabel: UILabel!
	@IBOutlet weak var senderLabel: UILabel!
	@IBOutlet weak var dateLabel: UILabel!

	override func awakeFromNib() {
		super.awakeFromNib()
		// Initialization code
	}

	override func setSelected(_ selected: Bool, animated: Bool) {
		super.setSelected(selected, animated: animated)

		// Configure the view for the selected state
	}
}
