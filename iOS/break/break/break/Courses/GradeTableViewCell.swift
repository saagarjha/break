//
//  GradeTableViewCell.swift
//  break
//
//  Created by Saagar Jha on 1/19/16.
//  Copyright © 2016 Saagar Jha. All rights reserved.
//

import UIKit

class GradeTableViewCell: UITableViewCell, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate {

	weak var progressReportViewController: ProgressReportViewController!
	var indexPath: IndexPath!
	var categories: [String]!

	@IBOutlet weak var titleLabel: UILabel! {
		didSet {
			titleLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(GradeTableViewCell.changeTitle(_:))))
		}
	}
	@IBOutlet weak var scoreLabel: UILabel! {
		didSet {
			scoreLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(GradeTableViewCell.changeScore(_:))))
		}
	}
	@IBOutlet weak var maxPointsLabel: UILabel! {
		didSet {
			maxPointsLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(GradeTableViewCell.changeMaxPoints(_:))))
		}
	}
	@IBOutlet weak var categoryNameLabel: UILabel! {
		didSet {
			categoryNameLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(GradeTableViewCell.changeCategoryName(_:))))
		}
	}
	@IBOutlet weak var percentScoreLabel: UILabel! {
		didSet {
			percentScoreLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(GradeTableViewCell.changePercentScore(_:))))
		}
	}

	var categoryTextField: UITextField!

	override func awakeFromNib() {
		super.awakeFromNib()
		// Initialization code
	}

	override func setSelected(_ selected: Bool, animated: Bool) {
		super.setSelected(selected, animated: animated)

		// Configure the view for the selected state
	}

	func changeTitle(_ sender: Any) {
		let alertController = UIAlertController(title: "Change Title", message: "Enter a new title for \"\(titleLabel.text ?? "")\".", preferredStyle: .alert)
		let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
		let doneAction = UIAlertAction(title: "Done", style: .default) { _ in
			guard let text = alertController.textFields?.first?.text else {
				assertionFailure("Could not get text from text field")
				return
			}
			self.progressReportViewController.changedTitle(to: text, forIndexPath: self.indexPath)
		}
		alertController.addAction(cancelAction)
		alertController.addAction(doneAction)
		alertController.addTextField { textField in
			textField.placeholder = "New Title"
			textField.text = self.titleLabel.text ?? ""
			textField.delegate = self
		}
		progressReportViewController.present(alertController, animated: true, completion: nil)
	}

	func changeScore(_ sender: Any?) {
		let alertController = UIAlertController(title: "Change Score", message: "Enter a new score for \"\(titleLabel.text ?? "")\".", preferredStyle: .alert)
		let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
		let doneAction = UIAlertAction(title: "Done", style: .default) { _ in
			guard let text = alertController.textFields?.first?.text else {
				assertionFailure("Could not get text from text field")
				return
			}
			self.progressReportViewController.changedScore(to: text, forIndexPath: self.indexPath)
		}
		alertController.addAction(cancelAction)
		alertController.addAction(doneAction)
		alertController.addTextField { textField in
			textField.placeholder = "New Score"
			textField.text = self.scoreLabel.text ?? ""
			textField.keyboardType = .decimalPad
			textField.delegate = self
		}
		progressReportViewController.present(alertController, animated: true, completion: nil)

	}

	func changeMaxPoints(_ sender: Any?) {
		let alertController = UIAlertController(title: "Change Max Value", message: "Enter a new max value for \"\(titleLabel.text ?? "")\".", preferredStyle: .alert)
		let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
		let doneAction = UIAlertAction(title: "Done", style: .default) { _ in
			guard let text = alertController.textFields?.first?.text else {
				assertionFailure("Could not get text from text field")
				return
			}
			self.progressReportViewController.changedMaxPoints(to: text, forIndexPath: self.indexPath)
		}
		alertController.addAction(cancelAction)
		alertController.addAction(doneAction)
		alertController.addTextField { textField in
			textField.placeholder = "New Max Points"
			textField.text = self.maxPointsLabel.text ?? ""
			textField.keyboardType = .decimalPad
			textField.delegate = self
		}
		progressReportViewController.present(alertController, animated: true, completion: nil)
	}

	func changeCategoryName(_ sender: Any) {
		let alertController = UIAlertController(title: "Change Category", message: "Enter a new category for \"\(titleLabel.text ?? "")\".", preferredStyle: .alert)
		let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
		let doneAction = UIAlertAction(title: "Done", style: .default) { _ in
			guard let text = alertController.textFields?.first?.text else {
				assertionFailure("Could not get text from text field")
				return
			}
			self.progressReportViewController.changedCategoryName(to: text, forIndexPath: self.indexPath)
		}
		alertController.addAction(cancelAction)
		alertController.addAction(doneAction)
		alertController.addTextField { textField in
			self.categoryTextField = textField
			textField.tintColor = .clear
			textField.text = self.categoryNameLabel.text ?? ""
			let pickerView = UIPickerView()
			pickerView.dataSource = self
			pickerView.delegate = self
			pickerView.selectRow(self.categories.index(of: textField.text ?? "") ?? 0, inComponent: 0, animated: false)
			textField.inputView = pickerView
			textField.delegate = self
		}
		progressReportViewController.present(alertController, animated: true, completion: nil)
	}

	func changePercentScore(_ sender: Any) {
		let alertController = UIAlertController(title: "Change Percent Score", message: "Enter a new percent score for \"\(titleLabel.text ?? "")\".", preferredStyle: .alert)
		let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
		let doneAction = UIAlertAction(title: "Done", style: .default) { _ in
			guard let text = alertController.textFields?.first?.text else {
				assertionFailure("Could not get text from text field")
				return
			}
			self.progressReportViewController.changedPercentScore(to: text, forIndexPath: self.indexPath)
		}
		alertController.addAction(cancelAction)
		alertController.addAction(doneAction)
		alertController.addTextField { textField in
			textField.placeholder = "New Percent Score"
			if let text = self.percentScoreLabel.text {
				textField.text = text.hasSuffix("%") ? text.substring(to: text.index(before: text.endIndex)) : text
			} else {
				textField.text = self.percentScoreLabel.text ?? ""
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
		progressReportViewController.present(alertController, animated: true, completion: nil)
	}

	func textFieldDidBeginEditing(_ textField: UITextField) {
		if textField !== categoryTextField {
			textField.selectedTextRange = textField.textRange(from: textField.beginningOfDocument, to: textField.endOfDocument)
		}
	}
	
	func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
		return textField !== categoryTextField
	}

	func numberOfComponents(in pickerView: UIPickerView) -> Int {
		return 1
	}

	func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		return categories.count
	}

	func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
		return categories[row]
	}

	func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
		categoryTextField.text = categories[row]
	}
}
