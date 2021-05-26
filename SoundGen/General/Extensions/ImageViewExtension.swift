//
//  ImageExtension.swift
//  SoundGen
//
//  Created by Michael Mityushkin on 2021-05-03.
//

import UIKit


extension UIImageView {
	func load(url: URL) {
		DispatchQueue.global().async { [weak self] in
			if let data = try? Data(contentsOf: url) {
				if let image = UIImage(data: data) {
					DispatchQueue.main.async {
						self?.image = image
					}
				}
			}
		}
	}
}
