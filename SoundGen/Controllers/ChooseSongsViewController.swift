//
//  ChooseSongsViewController.swift
//  SoundGen
//
//  Created by Michael Mityushkin on 2021-05-03.
//

import UIKit
import Alamofire

class ChooseSongsViewController: UIViewController {
	
	@IBOutlet weak var navigationBar: UINavigationBar!
	@IBOutlet weak var titleLabel: UILabel!
	
	@IBOutlet weak var playlistTypePicker: UIPickerView!
	@IBOutlet weak var selectPlaylistTypeDescriptionLabel: UILabel!
	@IBOutlet weak var selectPlaylistTypeDescriptionLabelToSeparatorConstraint: NSLayoutConstraint!
	@IBOutlet weak var selectPlaylistTypeDescriptionLabelHeightConstraint: NSLayoutConstraint!
	
	
	@IBOutlet weak var selectedSongsTableView: UITableView!
	
	@IBOutlet weak var playlistNameTextField: UITextField!
	
	@IBOutlet weak var generateButton: UIButton!
	
	let spinner = LoadingView()
	var timer: Timer?
	
	var textFields: [UITextField] = []
	
	var textFieldsHoldAlert = [false]
	var cellsHoldAlert = [false, false, false]
	
	let playlistTypes = ["No Selection", "Same Artists & Era", "Same Artists Top Hits", "New Artists"]
	let playlistTypesIdentifiers = [nil, "same-artists-dates", "same-artists", "new-artists"]
	let playlistTypesDescriptions = ["Please select a playlist type", "Songs from the same artists and time period as your 3 selected songs", "All time hits from the same artists as your 3 selected songs", "Popular songs from new similar artists as your 3 selected songs"]
	
	var selectedSongs: [SongModel?] = [nil, nil, nil]
	var selectedIndex = 0
	
	var parameters: Parameters?
	
	var featuredSongs: [SongModel] = []
	var playlistLink: URL?
	var playlistName: String?
	
	
	override func viewDidLoad() {
        super.viewDidLoad()
		
		selectedSongsTableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: selectedSongsTableView.frame.size.width, height: 1))
		
		textFields = [playlistNameTextField]
		UITextField.format(textFields: textFields, height: 40, padding: 10)
		
		selectedSongsTableView.register(UINib(nibName: K.Nibs.songCellNibName, bundle: nil), forCellReuseIdentifier: K.Identifiers.songCell)
		
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
		if segue.destination is SearchSongsViewController {
			let searchSongsVC = segue.destination as! SearchSongsViewController
			searchSongsVC.chooseSongsVC = self
		} else if segue.destination is PlaylistResultsViewController {
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
	
	@IBAction func playlistNameChanged(_ sender: UITextField) {
		setGenerateButtonState(enabled: allFieldsValid(updateUI: false))
	}
	
	func animatePlaylistTypeDescriptionLabel(show: Bool) {
		if show {
			selectPlaylistTypeDescriptionLabelHeightConstraint.constant = playlistTypePicker.selectedRow(inComponent: 0) == 0 ? 30 : 50
			selectPlaylistTypeDescriptionLabelToSeparatorConstraint.constant = 10
		} else {
			selectPlaylistTypeDescriptionLabelHeightConstraint.constant = 0
			selectPlaylistTypeDescriptionLabelToSeparatorConstraint.constant = 0
		}
		UIView.animate(withDuration: 0.5) {
			self.view.layoutIfNeeded()
		}
	}
	
	func updatePlaylistTypeDescriptionLabel(index: Int) {
		print("BKLLLJJHH")
		selectPlaylistTypeDescriptionLabel.text = playlistTypesDescriptions[index]
		selectPlaylistTypeDescriptionLabel.textColor = index == 0 ? .systemRed : .white
	}
	
	func allFieldsValid(updateUI: Bool) -> Bool {
		var isValid = true
		
		if playlistTypePicker.selectedRow(inComponent: 0) == 0 {
			isValid = false
			if updateUI {
				updatePlaylistTypeDescriptionLabel(index: 0)
				animatePlaylistTypeDescriptionLabel(show: true)
			}
		}
		
		for i in 0..<selectedSongs.count {
			if selectedSongs[i] == nil {
				isValid = false
				if updateUI {
					cellsHoldAlert[i] = true
					selectedSongsTableView.reloadData()
				}
			}
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
		
//		parameters = [
//			"song1" : "57BGVV6wcyhbn3hsjlqEZB",
//			"song2" : "3tDqEKKUs6gf8zMvSuLyLA",
//			"song3" : "2h4cmbyb6S7e8igDZIITJU",
//			"type" : "same-artists-dates",
//			"playlistName" : "Bruh",
//			"user" : "abiras2"
//		]
//
//		let spotifyOptionsVC = storyboard?.instantiateViewController(withIdentifier: K.StoryboardIDs.spotifyOptionsVC) as! SpotifyOptionsViewController
//		spotifyOptionsVC.modalPresentationStyle = .custom
//		spotifyOptionsVC.transitioningDelegate = self
//		spotifyOptionsVC.chooseSongsVC = self
//		spotifyOptionsVC.fromChooseSongs = true
//
//		present(spotifyOptionsVC, animated: true)
//		return
		
		///////////////////////////////////////////////////////////////////////////////////////////////
		
		let valid = allFieldsValid(updateUI: true)
		setGenerateButtonState(enabled: valid)
		
		if valid {
			
			guard let playlistName = playlistNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !playlistName.isEmpty, let song1ID = selectedSongs[0]?.id, let song2ID = selectedSongs[1]?.id, let song3ID = selectedSongs[2]?.id, let type = playlistTypesIdentifiers[playlistTypePicker.selectedRow(inComponent: 0)] else {
				showErrorMessage()
				return
			}
			
			print(song1ID)
			print(song2ID)
			print(song3ID)
			print(type)
			
			parameters = [
				"song1" : song1ID,
				"song2" : song2ID,
				"song3" : song3ID,
				"type" : type,
				"playlistName" : playlistName,
				"user" : "abiras2"
			]
			
			let spotifyOptionsVC = storyboard?.instantiateViewController(withIdentifier: K.StoryboardIDs.spotifyOptionsVC) as! SpotifyOptionsViewController
			spotifyOptionsVC.modalPresentationStyle = .custom
			spotifyOptionsVC.transitioningDelegate = self
			spotifyOptionsVC.chooseSongsVC = self
			spotifyOptionsVC.fromChooseSongs = true
			
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
			AF.request("http://192.241.139.120/custom_recommendation", method: .post, parameters: parameters, encoding: URLEncoding.default, headers: headers).validate(statusCode: 200 ..< 299).responseJSON { AFdata in
				
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
								self.performSegue(withIdentifier: K.Segues.chooseSongsToPlaylistResults, sender: self)
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
		Alerts.showNoOptionAlert(title: "An Error Occurred", message: "Please try reselecting your 3 songs", sender: self)
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





extension ChooseSongsViewController: UITableViewDelegate, UITableViewDataSource {
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 3
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let cell = tableView.dequeueReusableCell(withIdentifier: K.Identifiers.songCell, for: indexPath) as! SongTableViewCell
		
		let song = selectedSongs[indexPath.row]
		
		if let song = song {
			cell.songName.text = song.name
			cell.artistName.text = song.artist
			cell.songName.textColor = .white
			cell.artistName.textColor = .white
			if let image = song.image, image != K.Images.placeholderPhoto {
				cell.coverImage.image = image
			} else {
				cell.coverImage.image = K.Images.placeholderPhoto
				if let url = URL(string: song.imageURL) {
					cell.coverImage.load(url: url)
				} else {
					cell.coverImage.image = UIImage(systemName: "exclamationmark.icloud")
				}
			}
		} else {
			cell.songName.text = "No Song Selected"
			cell.artistName.text = "Tap to select a song"
			cell.coverImage.image = UIImage(systemName: "photo")
			if cellsHoldAlert[indexPath.row] {
				cell.songName.textColor = .systemRed
				cell.artistName.textColor = .systemRed
			} else {
				cell.songName.textColor = .white
				cell.artistName.textColor = .white
			}
		}
		
		
		
		return cell
		
	}
	
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		selectedIndex = indexPath.row
		tableView.deselectRow(at: indexPath, animated: true)
		performSegue(withIdentifier: K.Segues.chooseSongsToSearch, sender: self)
	}
	
}






extension ChooseSongsViewController: UIScrollViewDelegate {
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




extension ChooseSongsViewController: UIPickerViewDataSource, UIPickerViewDelegate {
	
	func numberOfComponents(in pickerView: UIPickerView) -> Int {
		return 1
	}
	
	func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		return playlistTypes.count
	}
	
	func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
		if row == 0 {
			return NSAttributedString(string: playlistTypes[row], attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemRed.withAlphaComponent(0.8)])
		} else {
			return NSAttributedString(string: playlistTypes[row], attributes: [NSAttributedString.Key.foregroundColor: K.Colors.goldColor ?? .white])
		}
	}
	
	func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
		setGenerateButtonState(enabled: allFieldsValid(updateUI: false))
		updatePlaylistTypeDescriptionLabel(index: row)
		animatePlaylistTypeDescriptionLabel(show: row == 0 ? false : true)
	}
	
}



extension ChooseSongsViewController: UITextFieldDelegate {
	
	func textFieldDidBeginEditing(_ textField: UITextField) {
		playlistNameTextField.changePlaceholderText(to: "Playlist name", withColor: K.Colors.placeholderTextColor ?? .systemGray3)
	}
	
}




extension ChooseSongsViewController: UIViewControllerTransitioningDelegate {
	func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
		return PresentationController(presentedViewController: presented, presenting: presentingViewController)
	}
}
