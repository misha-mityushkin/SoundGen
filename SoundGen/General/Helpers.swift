//
//  Helpers.swift
//  SoundGen
//
//  Created by Michael Mityushkin on 2021-05-09.
//

import UIKit


struct Helpers {
	
	static func getImageFromUrl(urlString: String) -> UIImage? {
		if let url = URL(string: urlString) {
			if let data = try? Data(contentsOf: url) {
				if let image = UIImage(data: data) {
					return image
				} else {
					return nil
				}
			} else {
				return nil
			}
		} else {
			return nil
		}
	}
	
}
