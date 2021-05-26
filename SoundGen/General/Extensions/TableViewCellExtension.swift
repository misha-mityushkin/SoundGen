//
//  TableViewCellExtension.swift
//  SoundGen
//
//  Created by Michael Mityushkin on 2021-05-03.
//

import UIKit

extension UITableViewCell {
	func addDisclosureIndicator() {
		let button = UIButton(frame: CGRect(x: 0, y: 0, width: 15, height: 15))
		button.setImage(UIImage(systemName: K.ImageNames.chevronRight), for: .normal)
		button.tintColor = .gray
		self.accessoryView = button
	}
}
