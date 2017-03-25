//
//  CourseDetailTableViewCell.swift
//  break
//
//  Created by Saagar Jha on 2/23/17.
//  Copyright © 2017 Saagar Jha. All rights reserved.
//

import UIKit

class CourseDetailTableViewCell: UITableViewCell, UITextFieldDelegate {

	weak var courseViewController: CourseViewController!
	var indexPath: IndexPath!

	var titleLabel = UILabel()
	var subtitleLabel = UILabel()

	var isTappable = false {
		didSet {
			[titleLabel, subtitleLabel].forEach { label in
				label.gestureRecognizers?.forEach { recognizer in
					label.removeGestureRecognizer(recognizer)
				}
				label.isUserInteractionEnabled = false
			}
			if isTappable {
				titleLabel.isUserInteractionEnabled = true
				titleLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(CourseDetailTableViewCell.changeTitle(_:))))
				subtitleLabel.isUserInteractionEnabled = true
				subtitleLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(CourseDetailTableViewCell.changeSubtitle(_:))))
			}
		}
	}

	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: .value1, reuseIdentifier: reuseIdentifier)
		var constraints = [NSLayoutConstraint]()

		for (copy, original) in zip([titleLabel, subtitleLabel], [textLabel, detailTextLabel]) {
			copy.font = original?.font
			copy.textColor = original?.textColor
			contentView.addSubview(copy)
			copy.translatesAutoresizingMaskIntoConstraints = false
			copy.numberOfLines = 0
			constraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|-(>=12)-[label]-(>=12)-|", options: [], metrics: nil, views: ["label": copy])
			copy.setContentHuggingPriority(UILayoutPriorityRequired, for: .vertical)
		}
		constraints += NSLayoutConstraint.constraints(withVisualFormat: "|-[title]-(>=8)-[subtitle]-|", options: [], metrics: nil, views: ["title": titleLabel, "subtitle": subtitleLabel])
		constraints.append(NSLayoutConstraint(item: titleLabel, attribute: .centerY, relatedBy: .equal, toItem: subtitleLabel, attribute: .centerY, multiplier: 1, constant: 0))
		constraints.append(NSLayoutConstraint(item: contentView, attribute: .centerY, relatedBy: .equal, toItem: titleLabel, attribute: .centerY, multiplier: 1, constant: 0))
		subtitleLabel.setContentCompressionResistancePriority(UILayoutPriorityRequired, for: .horizontal)
		NSLayoutConstraint.activate(constraints)
	}

	required init?(coder aDecoder: NSCoder) {
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

	func changeTitle(_ sender: Any) {
		let alertController = UIAlertController(title: "Rename Category", message: "Enter a new category name for \"\(titleLabel.text ?? "")\".", preferredStyle: .alert)
		let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
		let doneAction = UIAlertAction(title: "Done", style: .default) { _ in
			guard let text = alertController.textFields?.first?.text else {
				assertionFailure("Could not get text from text field")
				return
			}
			self.courseViewController.changedTitle(to: text, forIndexPath: self.indexPath)
		}
		alertController.addAction(cancelAction)
		alertController.addAction(doneAction)
		alertController.addTextField { textField in
			textField.placeholder = "New Category Name"
			textField.text = self.titleLabel.text ?? ""
			textField.delegate = self

		}
		courseViewController.present(alertController, animated: true, completion: nil)
	}

	func changeSubtitle(_ sender: UILabel) {
		let alertController = UIAlertController(title: "Change Weight", message: "Enter a new weight for \"\(titleLabel.text ?? "")\".", preferredStyle: .alert)
		let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
		let doneAction = UIAlertAction(title: "Done", style: .default) { _ in
			guard let text = alertController.textFields?.first?.text else {
				assertionFailure("Could not get text from text field")
				return
			}
			self.courseViewController.changedSubtitle(to: text, forIndexPath: self.indexPath)
		}
		alertController.addAction(cancelAction)
		alertController.addAction(doneAction)
		alertController.addTextField { textField in
			textField.placeholder = "New Weight"
			if let text = self.subtitleLabel.text {
				textField.text = text.hasSuffix("%") ? text.substring(to: text.index(before: text.endIndex)) : text
			} else {
				textField.text = self.subtitleLabel.text ?? ""
			}
			textField.keyboardType = .decimalPad
			let label = UILabel()
			label.font = textField.font
			label.isEnabled = false
			label.text = "%"
			label.frame.size = label.intrinsicContentSize
			textField.rightView = label
			textField.rightViewMode = .always
			textField.delegate = self
		}
		courseViewController.present(alertController, animated: true, completion: nil)
	}

	func textFieldDidBeginEditing(_ textField: UITextField) {
		textField.selectedTextRange = textField.textRange(from: textField.beginningOfDocument, to: textField.endOfDocument)
	}
}
