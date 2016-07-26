//
//  AssignmentTableViewCell.swift
//  break
//
//  Created by Saagar Jha on 1/20/16.
//  Copyright © 2016 Saagar Jha. All rights reserved.
//

import UIKit

class AssignmentTableViewCell: UITableViewCell {

	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var courseNameLabel: UILabel!

	override func awakeFromNib() {
		super.awakeFromNib()
		// Initialization code
	}

	override func setSelected(_ selected: Bool, animated: Bool) {
		super.setSelected(selected, animated: animated)

		// Configure the view for the selected state
	}
}
