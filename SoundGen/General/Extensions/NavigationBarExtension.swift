//
//  NavigationBarExtension.swift
//  SoundGen
//
//  Created by Michael Mityushkin on 2021-05-02.
//

import UIKit

extension UINavigationBar {
	
	func makeTransparent() {
		setBackgroundImage(UIImage(), for: .default)
		shadowImage = UIImage()
		isTranslucent = true
	}
	
	func returnToOriginalState() {
		setBackgroundImage(nil, for: .default)
		shadowImage = nil
	}
	
}
