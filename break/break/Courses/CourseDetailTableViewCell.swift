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

	var discriminatorView = UIView()
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
				titleLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(changeTitle)))
				subtitleLabel.isUserInteractionEnabled = true
				subtitleLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(changeSubtitle)))
			}
		}
	}

	override init(style: CellStyle, reuseIdentifier: String?) {
		super.init(style: .value1, reuseIdentifier: reuseIdentifier)
		var constraints = [NSLayoutConstraint]()

		for (copy, original) in zip([titleLabel, subtitleLabel], [textLabel, detailTextLabel]) {
			copy.font = original?.font
			copy.textColor = original?.textColor
			contentView.addSubview(copy)
			copy.translatesAutoresizingMaskIntoConstraints = false
			copy.numberOfLines = 0
			constraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|-(>=\(breakConstants.tableViewCellVerticalPadding))-[label]-(>=\(breakConstants.tableViewCellVerticalPadding))-|", options: [], metrics: nil, views: ["label": copy])
			copy.setContentHuggingPriority(.required, for: .vertical)
		}
		constraints += NSLayoutConstraint.constraints(withVisualFormat: "|-[title]-(>=8)-[subtitle]-|", options: [], metrics: nil, views: ["title": titleLabel, "subtitle": subtitleLabel])
		constraints.append(NSLayoutConstraint(item: titleLabel, attribute: .centerY, relatedBy: .equal, toItem: subtitleLabel, attribute: .centerY, multiplier: 1, constant: 0))
		constraints.append(NSLayoutConstraint(item: contentView, attribute: .centerY, relatedBy: .equal, toItem: titleLabel, attribute: .centerY, multiplier: 1, constant: 0))
		subtitleLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
		discriminatorView.translatesAutoresizingMaskIntoConstraints = false
		contentView.addSubview(discriminatorView)
		constraints += NSLayoutConstraint.constraints(withVisualFormat: "|[discriminator]", options: [], metrics: nil, views: ["discriminator": discriminatorView])
		constraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|[discriminator]", options: [], metrics: nil, views: ["discriminator": discriminatorView])
		constraints.append(NSLayoutConstraint(item: discriminatorView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0))
		constraints.append(NSLayoutConstraint(item: discriminatorView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: breakConstants.discriminatorViewWidth))
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

	@objc func changeTitle(_ sender: Any) {
		let alertController = UIAlertController(title: "Rename Category", message: "Enter a new category name for \"\(titleLabel.text ?? "")\".", preferredStyle: .alert)
		let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
		let doneAction = UIAlertAction(title: "Done", style: .default) { _ in
			guard let text = alertController.textFields?.first?.text else {
				assertionFailure("Could not get text from text field")
				return
			}
			self.courseViewController.changedTitle(to: text, for: self.indexPath)
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

	@objc func changeSubtitle(_ sender: UILabel) {
		let alertController = UIAlertController(title: "Change Weight", message: "Enter a new weight for \"\(titleLabel.text ?? "")\".", preferredStyle: .alert)
		let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
		let doneAction = UIAlertAction(title: "Done", style: .default) { _ in
			guard let text = alertController.textFields?.first?.text else {
				assertionFailure("Could not get text from text field")
				return
			}
			self.courseViewController.changedSubtitle(to: text, for: self.indexPath)
		}
		alertController.addAction(cancelAction)
		alertController.addAction(doneAction)
		alertController.addTextField { textField in
			textField.placeholder = "New Weight"
			if let text = self.subtitleLabel.text {
				textField.text = text.hasSuffix("%") ? String(text[..<text.index(before: text.endIndex)]) : text
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
