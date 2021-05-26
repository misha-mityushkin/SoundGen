//
//  StringExtension.swift
//  SoundGen
//
//  Created by Michael Mityushkin on 2021-05-18.
//

import Foundation

extension String {
	
	func getYearMonthDay() -> [String] {
		var dateComponentsArray: [String] = []
		let components = self.split(separator: "-")
		for i in 0..<components.count {
			let component = components[i]
			if i == 1 { //if its the month component
				switch Int(String(component)) {
					case 1: dateComponentsArray.append("January")
					case 2: dateComponentsArray.append("February")
					case 3: dateComponentsArray.append("March")
					case 4: dateComponentsArray.append("April")
					case 5: dateComponentsArray.append("May")
					case 6: dateComponentsArray.append("June")
					case 7: dateComponentsArray.append("July")
					case 8: dateComponentsArray.append("August")
					case 9: dateComponentsArray.append("September")
					case 10: dateComponentsArray.append("October")
					case 11: dateComponentsArray.append("November")
					case 12: dateComponentsArray.append("December")
					default:
						dateComponentsArray.append("Unknown Month")
				}
			} else {
				dateComponentsArray.append(String(component))
			}
		}
		return dateComponentsArray
	}
	
	func formattedDate() -> String {
		let dateComponents = self.getYearMonthDay()
		let year = dateComponents[0]
		let month = dateComponents[1]
		let day = String(Int(dateComponents[2]) ?? 0)
		return "\(month) \(day), \(year)"
	}
	
}
