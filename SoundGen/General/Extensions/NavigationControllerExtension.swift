//
//  NavigationControllerExtension.swift
//  SoundGen
//
//  Created by Michael Mityushkin on 2021-05-02.
//

import UIKit

extension UINavigationController {
	
	func makeTransparent() {
		navigationBar.setBackgroundImage(UIImage(), for: .default)
		navigationBar.shadowImage = UIImage()
		navigationBar.isTranslucent = true
	}
	
	func returnToOriginalState() {
		navigationBar.setBackgroundImage(nil, for: .default)
		navigationBar.shadowImage = nil
	}
	
}
