//
//  TextFieldExtension.swift
//  SoundGen
//
//  Created by Michael Mityushkin on 2021-05-09.
//

import UIKit


extension UITextField {
	
	func changeTextFieldColor(color: UIColor, size: CGSize) {
		UIGraphicsBeginImageContext(self.frame.size)
		color.setFill()
		UIBezierPath(rect: self.frame).fill()
		let bgImage = UIGraphicsGetImageFromCurrentImageContext()!
		UIGraphicsEndImageContext()
		self.background = bgImage
	}
	
	func setLeftPaddingPoints(_ amount:CGFloat){
		let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
		self.leftView = paddingView
		self.leftViewMode = .always
	}
	func setRightPaddingPoints(_ amount:CGFloat) {
		let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
		self.rightView = paddingView
		self.rightViewMode = .always
	}
	
	static func format(textFields: [UITextField], height: CGFloat, padding: CGFloat) {
		for textField in textFields {
			if #available(iOS 13.0, *) {
				textField.attributedPlaceholder = NSAttributedString(string: textField.placeholder ?? "", attributes: [NSAttributedString.Key.foregroundColor: K.Colors.placeholderTextColor ?? UIColor.gray])
			}
			textField.layer.backgroundColor = (K.Colors.goldColor ?? .black).cgColor
			//textField.changeTextFieldColor(color: UIColor(named: K.ColorNames.goldColor) ?? .black, size: CGSize(width: textField.frame.size.width, height: height))
			textField.setLeftPaddingPoints(padding)
		}
	}
	
	static func formatBackground(textFields: [UITextField], height: CGFloat, padding: CGFloat) {
		for textField in textFields {
			textField.changeTextFieldColor(color: UIColor(named: K.ColorNames.goldColor) ?? .black, size: CGSize(width: textField.frame.size.width, height: height))
			textField.setLeftPaddingPoints(padding)
		}
	}
	
	static func formatPlaceholder(textFields: [UITextField], height: CGFloat, padding: CGFloat) {
		for textField in textFields {
			textField.changeTextFieldColor(color: UIColor(named: K.ColorNames.goldColor) ?? .black, size: CGSize(width: textField.frame.size.width, height: height))
			textField.setLeftPaddingPoints(padding)
		}
	}
	
	func changePlaceholderText(to newText: String, withColor color: UIColor) {
		attributedPlaceholder = NSAttributedString(string: newText, attributes: [NSAttributedString.Key.foregroundColor: color])
	}
	
	func changePlaceholderText(to newText: String) {
		attributedPlaceholder = NSAttributedString(string: newText, attributes: [NSAttributedString.Key.foregroundColor: UIColor(named: K.ColorNames.placeholderTextColor) ?? UIColor.gray])
	}
	
}
