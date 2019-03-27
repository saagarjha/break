//
//  ProgressReportHeaderTableViewCell.swift
//  break
//
//  Created by Saagar Jha on 2/15/17.
//  Copyright © 2017 Saagar Jha. All rights reserved.
//

import UIKit

class ProgressReportHeaderTableViewCell: UITableViewCell {

	static let normalFont = UIFont.preferredFont(forTextStyle: .title3)
	static let boldFont = UIFont(descriptor: normalFont.fontDescriptor.withSymbolicTraits(.traitBold)!, size: normalFont.pointSize)

	var discriminatorView: UIView
	var titleLabel: UILabel
	var subtitleLabel: UILabel

	var isBold = false {
		didSet {
			if isBold {
				titleLabel.font = ProgressReportHeaderTableViewCell.boldFont
				subtitleLabel.font = ProgressReportHeaderTableViewCell.boldFont
			} else {
				titleLabel.font = ProgressReportHeaderTableViewCell.normalFont
				subtitleLabel.font = ProgressReportHeaderTableViewCell.normalFont
			}
		}
	}

	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		discriminatorView = UIView()
		titleLabel = UILabel()
		subtitleLabel = UILabel()
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		contentView.addSubview(discriminatorView)
		contentView.addSubview(titleLabel)
		contentView.addSubview(subtitleLabel)

		var constraints = NSLayoutConstraint.constraints(withVisualFormat: "|-[title]-(>=8)-[subtitle]-|", options: [], metrics: nil, views: ["title": titleLabel, "subtitle": subtitleLabel])
		constraints.append(NSLayoutConstraint(item: titleLabel, attribute: .centerY, relatedBy: .equal, toItem: subtitleLabel, attribute: .centerY, multiplier: 1, constant: 0))
		for label in [titleLabel, subtitleLabel] {
			label.font = ProgressReportHeaderTableViewCell.normalFont
			label.translatesAutoresizingMaskIntoConstraints = false
			label.numberOfLines = 0
			constraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|-(>=4)-[label]-(>=4)-|", options: [], metrics: nil, views: ["label": label])
			label.setContentHuggingPriority(.required, for: .vertical)
		}
		subtitleLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

		discriminatorView.translatesAutoresizingMaskIntoConstraints = false
		constraints += NSLayoutConstraint.constraints(withVisualFormat: "|[discriminator]", options: [], metrics: nil, views: ["discriminator": discriminatorView])
		constraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|[discriminator]|", options: [], metrics: nil, views: ["discriminator": discriminatorView])
		constraints.append(NSLayoutConstraint(item: discriminatorView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: breakConstants.discriminatorViewWidth))
		NSLayoutConstraint.activate(constraints)
	}

	required init?(coder aDecoder: NSCoder) {
		discriminatorView = UIView()
		titleLabel = UILabel()
		subtitleLabel = UILabel()
		super.init(coder: aDecoder)
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
