//
//  CourseTableViewCell.swift
//  break
//
//  Created by Saagar Jha on 1/19/16.
//  Copyright © 2016 Saagar Jha. All rights reserved.
//

import UIKit

class CourseTableViewCell: UITableViewCell {

	@IBOutlet weak var periodLabel: UILabel!
	@IBOutlet weak var courseNameLabel: UILabel!
	@IBOutlet weak var teacherNameLabel: UILabel!
	@IBOutlet weak var gradeLabel: UILabel!
	@IBOutlet weak var scoreLabel: UILabel!

	override func awakeFromNib() {
		super.awakeFromNib()
		// Initialization code
	}

	override func setSelected(_ selected: Bool, animated: Bool) {
		super.setSelected(selected, animated: animated)

		// Configure the view for the selected state
	}
}
