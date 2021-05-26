//
//  ChooseMusicTypeViewController.swift
//  SoundGen
//
//  Created by Michael Mityushkin on 2021-05-11.
//

import UIKit
import Alamofire

class ChooseMusicTypeViewController: UIViewController {
	
	@IBOutlet weak var navigationBar: UINavigationBar!
	@IBOutlet weak var titleLabel: UILabel!
	
	@IBOutlet weak var musicTypePicker: UIPickerView!
	@IBOutlet weak var selectMusicTypeErrorLabel: UILabel!
	@IBOutlet weak var selectMusicTypeErrorLabelToSeparatorConstraint: NSLayoutConstraint!
	@IBOutlet weak var selectMusicTypeErrorLabelHeightConstraint: NSLayoutConstraint!
	
	@IBOutlet weak var playlistNameTextField: UITextField!
	
	@IBOutlet weak var generateButton: UIButton!
	
	let spinner = LoadingView()
	var timer: Timer?
	
	var textFields: [UITextField] = []
	var textFieldsHoldAlert = [false]
	
	let musicTypes = ["No Selection", "Hot 100", "Streaming Songs", "Radio Songs", "80's Songs", "90's Songs", "Rap", "R&B", "R&B & Hip-Hop"]
	let musicTypesIdentifiers = [nil, "hot-100", "streaming-songs", "radio-songs", "80's playlist", "90's playlist", "rap", "R&B", "R&B & hiphop"]
	let musicTypesDescriptions = ["Please select a style or song type", "The hottest 100 songs right now", "Popular streaming songs???", "Popular radio songs", ""]
	
	var parameters: Parameters?
	
	var featuredSongs: [SongModel] = []
	var playlistLink: URL?
	var playlistName: String?
	
	var customNameIsEntered = false
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		textFields = [playlistNameTextField]
		UITextField.format(textFields: textFields, height: 40, padding: 10)
		isModalInPresentation = true
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		navigationBar.makeTransparent()
	}
	
	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		var nonAlteredTextFields: [UITextField] = []
		for i in 0..<textFieldsHoldAlert.count {
			if !textFieldsHoldAlert[i] {
				nonAlteredTextFields.append(textFields[i])
			}
		}
		UITextField.formatBackground(textFields: textFields, height: 40, padding: 10)
		UITextField.formatPlaceholder(textFields: nonAlteredTextFields, height: 40, padding: 10)
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.destination is PlaylistResultsViewController {
			let playlistResultsVC = segue.destination as! PlaylistResultsViewController
			playlistResultsVC.featuredSongs = featuredSongs
			playlistResultsVC.playlistLink = playlistLink
			playlistResultsVC.playlistName = playlistName
		}
	}
	
	
	@IBAction func cancelPressed(_ sender: UIBarButtonItem) {
		Alerts.showTwoOptionAlertDestructive(title: "Are you sure you want to exit?", message: "Your changes will not be saved", sender: self, option1: "Exit", option2: "Stay", is1Destructive: true, is2Destructive: false, handler1: { (_) in
			self.dismiss(animated: true, completion: nil)
		}, handler2: nil)
	}
	
	@IBAction func playlistNameUpdated(_ sender: UITextField) {
		setGenerateButtonState(enabled: allFieldsValid(updateUI: false))
		customNameIsEntered = sender.text?.isEmpty ?? true ? false : true
	}
	
	
	func animateMusicTypeErrorLabel(show: Bool) {
		if show {
			selectMusicTypeErrorLabelHeightConstraint.constant = 30
			selectMusicTypeErrorLabelToSeparatorConstraint.constant = 10
		} else {
			selectMusicTypeErrorLabelHeightConstraint.constant = 0
			selectMusicTypeErrorLabelToSeparatorConstraint.constant = 0
		}
		UIView.animate(withDuration: 0.5) {
			self.view.layoutIfNeeded()
		}
	}
	
	func allFieldsValid(updateUI: Bool) -> Bool {
		var isValid = true
		
		if musicTypePicker.selectedRow(inComponent: 0) == 0 {
			isValid = false
			if updateUI {
				animateMusicTypeErrorLabel(show: true)
			}
		} else {
			animateMusicTypeErrorLabel(show: false)
		}
		
		if playlistNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true {
			isValid = false
			if updateUI {
				textFieldsHoldAlert[0] = true
				textFields[0].changePlaceholderText(to: "Please provide a playlist name", withColor: .systemRed)
			}
		}
		
		return isValid
	}
	
	func setGenerateButtonState(enabled: Bool) {
		if enabled {
			generateButton.backgroundColor = K.Colors.otherButtonColor
		} else {
			generateButton.backgroundColor = K.Colors.darkGrayColor
		}
	}
	
	
	@IBAction func generatePlaylistPressed(_ sender: UIButton) {
		let valid = allFieldsValid(updateUI: true)
		setGenerateButtonState(enabled: valid)
		
		if valid {
			guard let playlistName = playlistNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !playlistName.isEmpty, let type = musicTypesIdentifiers[musicTypePicker.selectedRow(inComponent: 0)] else {
				showErrorMessage()
				return
			}
			
			parameters = [
				"playlistName" : playlistName,
				"hotpicks-type" : type
			]
			
			let spotifyOptionsVC = storyboard?.instantiateViewController(withIdentifier: K.StoryboardIDs.spotifyOptionsVC) as! SpotifyOptionsViewController
			spotifyOptionsVC.modalPresentationStyle = .custom
			spotifyOptionsVC.transitioningDelegate = self
			spotifyOptionsVC.chooseMusicTypeVC = self
			spotifyOptionsVC.fromChooseSongs = false
			
			UIImpactFeedbackGenerator(style: .medium).impactOccurred()
			present(spotifyOptionsVC, animated: true)
		} else {
			UINotificationFeedbackGenerator().notificationOccurred(.error)
			Alerts.showNoOptionAlert(title: "Incomplete Fields", message: "You have not filled out all the required fields", sender: self)
		}
	}
	
	
	func generatePlaylist() {
		if let parameters = parameters {
			print(parameters)
			spinner.create(parentVC: self)
			spinner.label.text = "Generating playlist..."
			timer = Timer.scheduledTimer(withTimeInterval: 10, repeats: false) { timer in
				if self.spinner.isActive {
					self.spinner.label.text = "This may take up to a minute..."
				}
			}
			playlistName = parameters["playlistName"] as? String ?? "Playlist Name"
			
			let headers = HTTPHeaders(["Content-Type": "application/x-www-form-urlencoded"])
			AF.request("http://192.241.139.120/general_recommendation", method: .post, parameters: parameters, encoding: URLEncoding.default, headers: headers).validate(statusCode: 200 ..< 299).responseJSON { AFdata in
				
				print("data: \(AFdata)")
				switch AFdata.result {
					case .success(let data):
						if let data = data as? [String : Any], let songs = data["preview"] as? [[String : String]], !songs.isEmpty, let playlistLinkString = data["playlist_link"] as? String, let playlistLink = URL(string: playlistLinkString) {
							print(songs)
							self.playlistLink = playlistLink
							for song in songs {
								if let name = song["song_name"], let artist = song["artist"], let imageURL = song["imgURL"] {
									print("name: \(name), artist: \(artist)")
									let songModel = SongModel(name: name, id: "", artist: artist, imageURL: imageURL)
									self.featuredSongs.append(songModel)
								} else {
									self.showServerErrorMessage()
									return
								}
							}
							self.timer?.invalidate()
							self.spinner.remove()
							UINotificationFeedbackGenerator().notificationOccurred(.success)
							Alerts.showOneOptionAlert(title: "Success!", message: "Your new playlist has been created", optionText: "View Playlist", sender: self) { _ in
								self.performSegue(withIdentifier: K.Segues.chooseMusicTypeToPlaylistResults, sender: self)
							}
						} else {
							self.showServerErrorMessage()
						}
						
					case .failure:
						self.showServerErrorMessage()
				}
				
			}
		} else {
			showErrorMessage()
		}
	}
	
	func showErrorMessage() {
		UINotificationFeedbackGenerator().notificationOccurred(.error)
		Alerts.showNoOptionAlert(title: "An Error Occurred", message: "Please try restarting the app", sender: self)
	}
	
	func showServerErrorMessage() {
		if spinner.isActive {
			timer?.invalidate()
			spinner.remove()
		}
		UINotificationFeedbackGenerator().notificationOccurred(.error)
		Alerts.showNoOptionAlert(title: "An Error Occurred", message: "We were unable to fetch results from the server", sender: self)
	}
	
}




extension ChooseMusicTypeViewController: UIScrollViewDelegate {
	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		if scrollView.contentOffset.y >= titleLabel.frame.maxY {
			if navigationBar.topItem?.title != titleLabel.text {
				navigationBar.topItem?.title = titleLabel.text
			}
		} else {
			if navigationBar.topItem?.title == titleLabel.text {
				navigationBar.topItem?.title = nil
			}
		}
	}
}




extension ChooseMusicTypeViewController: UIPickerViewDataSource, UIPickerViewDelegate {
	
	func numberOfComponents(in pickerView: UIPickerView) -> Int {
		return 1
	}
	
	func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		return musicTypes.count
	}
	
	func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
		if row == 0 {
			return NSAttributedString(string: musicTypes[row], attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemRed.withAlphaComponent(0.8)])
		} else {
			return NSAttributedString(string: musicTypes[row], attributes: [NSAttributedString.Key.foregroundColor: K.Colors.goldColor ?? .white])
		}
	}
	
	func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
		if !customNameIsEntered {
			if row == 0 {
				playlistNameTextField.text = ""
			} else {
				playlistNameTextField.text = "\(Date().dateStringWith(strFormat: K.Strings.dateFormatString).formattedDate()) \(musicTypes[row])"
			}
		}
		setGenerateButtonState(enabled: allFieldsValid(updateUI: row != 0 && selectMusicTypeErrorLabelHeightConstraint.constant != 0))
	}
	
}



extension ChooseMusicTypeViewController: UITextFieldDelegate {
	
	func textFieldDidBeginEditing(_ textField: UITextField) {
		playlistNameTextField.changePlaceholderText(to: "Playlist name", withColor: K.Colors.placeholderTextColor ?? .systemGray3)
	}
	
}



extension ChooseMusicTypeViewController: UIViewControllerTransitioningDelegate {
	func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
		return PresentationController(presentedViewController: presented, presenting: presentingViewController)
	}
}
