//
//  SearchBarExtension.swift
//  SoundGen
//
//  Created by Michael Mityushkin on 2021-05-11.
//

import UIKit

extension UISearchBar {
	
	public var textField: UITextField? {
		if #available(iOS 13.0, *) {
			return self.searchTextField
		} else {
			let subViews = subviews.flatMap { $0.subviews }
			guard let textField = (subViews.filter { $0 is UITextField }).first as? UITextField else {
				return nil
			}
			return textField
		}
	}
	
	public var activityIndicator: UIActivityIndicatorView? {
		return textField?.leftView?.subviews.compactMap{ $0 as? UIActivityIndicatorView }.first
	}
	
	var isLoading: Bool {
		get {
			return activityIndicator != nil
		} set {
			print("new: \(newValue), old: \(isLoading)")
			if newValue {
				if activityIndicator == nil && (textField?.leftView as? UIImageView)?.image == K.Images.searchIcon {
					let newActivityIndicator = UIActivityIndicatorView(style: .medium)
					newActivityIndicator.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
					newActivityIndicator.startAnimating()
					newActivityIndicator.backgroundColor = .clear
					newActivityIndicator.color = .black
					textField?.leftView = newActivityIndicator
					//textField?.leftView?.addSubview(newActivityIndicator)
					let leftViewSize = textField?.leftView?.frame.size ?? CGSize.zero
					newActivityIndicator.center = CGPoint(x: leftViewSize.width/2, y: leftViewSize.height/2)
				}
			} else {
				textField?.leftView = UIImageView(image: K.Images.searchIcon)
				//activityIndicator?.removeFromSuperview()
			}
		}
	}
	
}
