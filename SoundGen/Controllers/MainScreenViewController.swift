//
//  ViewController.swift
//  SoundGen
//
//  Created by Michael Mityushkin on 2021-05-01.
//

import UIKit

class MainScreenViewController: UIViewController {

	@IBOutlet weak var navigationBar: UINavigationBar!
	@IBOutlet weak var navBarLogo: UIBarButtonItem!
	
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var soundGenLogo: UIImageView!
	
	@IBOutlet weak var generateFromMusicTypeButton: UIButton!
	
	private let imageView = UIImageView(image: K.Images.placeholderPhoto)
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		navigationBar.makeTransparent()
	}

	@IBAction func generateBasedOnSongsPressed(_ sender: UIButton) {
		performSegue(withIdentifier: K.Segues.mainScreenToChooseSongs, sender: self)
	}
	
	@IBAction func generateFromGenrePressed(_ sender: UIButton) {
		performSegue(withIdentifier: K.Segues.mainScreenToChooseMusicType, sender: self)
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		
	}
	
}




extension MainScreenViewController: UIScrollViewDelegate {
	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		if scrollView.contentOffset.y >= titleLabel.frame.maxY {
			if navigationBar.topItem?.title != titleLabel.text {
				navigationBar.topItem?.title = titleLabel.text
				navBarLogo.image = soundGenLogo.image
			}
		} else {
			if navigationBar.topItem?.title == titleLabel.text {
				navigationBar.topItem?.title = nil
				navBarLogo.image = nil
			}
		}
	}
}

