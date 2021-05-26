//
//  DateExtension.swift
//  SoundGen
//
//  Created by Michael Mityushkin on 2021-05-18.
//

import Foundation


extension Date {
	
	var monthString: String {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "MMMM"
		return dateFormatter.string(from: self)
	}
	
	func dateStringWith(strFormat: String) -> String {
		let dateFormatter = DateFormatter()
		dateFormatter.timeZone = Calendar.current.timeZone
		dateFormatter.locale = Calendar.current.locale
		dateFormatter.dateFormat = strFormat
		return dateFormatter.string(from: self)
	}
	
}
