//
//  GradeTableViewCell.swift
//  break
//
//  Created by Saagar Jha on 1/19/16.
//  Copyright © 2016 Saagar Jha. All rights reserved.
//

import UIKit

class GradeTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var categoryNameLabel: UILabel!
    @IBOutlet weak var percentScoreLabel: UILabel!
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
