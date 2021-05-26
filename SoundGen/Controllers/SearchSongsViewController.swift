//
//  SearchSongsViewController.swift
//  SoundGen
//
//  Created by Michael Mityushkin on 2021-05-03.
//

import UIKit
import Alamofire

class SearchSongsViewController: UIViewController {
	
	@IBOutlet weak var navigationBar: UINavigationBar!
	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var searchInstructionsLabel: UILabel!
	
	var chooseSongsVC: ChooseSongsViewController?
	
	var resultSearchController: UISearchController?
	
	var songResults: [SongModel] = []
		
	var requestIndex = 0
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		tableView.backgroundView = UIImageView(image: UIImage(named: K.ImageNames.backgroundNoLogo))
		tableView.register(UINib(nibName: K.Nibs.songCellNibName, bundle: nil), forCellReuseIdentifier: K.Identifiers.songCell)
		
		searchInstructionsLabel.isHidden = false
		
		resultSearchController = UISearchController(searchResultsController: nil)
		resultSearchController?.searchResultsUpdater = self
		resultSearchController?.hidesNavigationBarDuringPresentation = false
		resultSearchController?.obscuresBackgroundDuringPresentation = false
		resultSearchController?.searchBar.isLoading = false
		
		
		let searchBar = resultSearchController!.searchBar
		searchBar.sizeToFit()
		searchBar.delegate = self
		searchBar.placeholder = "Enter a song name..."
		searchBar.searchTextField.attributedPlaceholder = NSAttributedString(string: "Enter a song name...", attributes: [NSAttributedString.Key.foregroundColor: UIColor(named: K.ColorNames.placeholderTextColor) ?? UIColor.gray])
		
		navigationItem.titleView = searchBar
	}
	
	
	
	@IBAction func closePressed(_ sender: UIBarButtonItem) {
		dismiss(animated: true, completion: nil)
	}
	
}





extension SearchSongsViewController: UITableViewDelegate, UITableViewDataSource {
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if songResults.count > 0 {
			searchInstructionsLabel.isHidden = true
			tableView.separatorStyle = .singleLine
		} else {
			searchInstructionsLabel.isHidden = false
			tableView.separatorStyle = .none
		}
		return songResults.count
	}
	
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let cell = tableView.dequeueReusableCell(withIdentifier: K.Identifiers.songCell, for: indexPath) as! SongTableViewCell
		let song = songResults[indexPath.row]
		
		cell.songName.text = song.name
		cell.artistName.text = song.artist
		cell.coverImage.image = K.Images.placeholderPhoto
		if let url = URL(string: song.imageURL) {
			cell.coverImage.load(url: url)
		} else {
			cell.coverImage.image = UIImage(systemName: "exclamationmark.icloud")
		}
		
		return cell
		
	}
	
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		var song = songResults[indexPath.row]
		resultSearchController?.isActive = false
		
		for selectedSong in chooseSongsVC?.selectedSongs ?? [] {
			if selectedSong?.id == song.id {
				UINotificationFeedbackGenerator().notificationOccurred(.error)
				Alerts.showNoOptionAlert(title: "Duplicate Song", message: "You have already selected this song", sender: self)
				return
			}
		}
		
		song.image = (tableView.cellForRow(at: indexPath) as? SongTableViewCell)?.coverImage.image
		chooseSongsVC?.selectedSongs[chooseSongsVC?.selectedIndex ?? 0] = song
		chooseSongsVC?.cellsHoldAlert[chooseSongsVC?.selectedIndex ?? 0] = false
		dismiss(animated: true) {
			self.chooseSongsVC?.selectedSongsTableView.reloadData()
			self.chooseSongsVC?.setGenerateButtonState(enabled: self.chooseSongsVC?.allFieldsValid(updateUI: false) ?? false)
		}
	}
	
}





extension SearchSongsViewController: UISearchResultsUpdating {
	
	func showServerErrorMessage() {
		UINotificationFeedbackGenerator().notificationOccurred(.error)
		resultSearchController?.searchBar.isLoading = false
		resultSearchController?.isActive = false
		Alerts.showNoOptionAlert(title: "An Error Occurred", message: "We were unable to fetch results from the server", sender: self)
	}
	
	func showNoResultsMessage() {
		UINotificationFeedbackGenerator().notificationOccurred(.warning)
		resultSearchController?.searchBar.isLoading = false
		resultSearchController?.isActive = false
		Alerts.showNoOptionAlert(title: "No Results Found", message: "Please check your search query and try again", sender: self)
	}
	
	func updateSearchResults(for searchController: UISearchController) {
		guard let searchText = searchController.searchBar.text?.lowercased().trimmingCharacters(in: .whitespacesAndNewlines), !searchText.isEmpty else {
			tableView.reloadData()
			return
			}
		
		var newSongResults: [SongModel] = []
		
		searchInstructionsLabel.isHidden = true
		resultSearchController?.searchBar.isLoading = true
		
		let currRequestNumber = requestIndex
		requestIndex += 1
		
		let headers = HTTPHeaders(["Content-Type": "application/x-www-form-urlencoded"])
		let params: Parameters = ["song_name" : searchText]
		
		
		AF.request("http://192.241.139.120/song_search", method: .post, parameters: params, encoding: URLEncoding.default, headers: headers).validate(statusCode: 200 ..< 299).responseJSON { AFdata in
			
			if currRequestNumber < self.requestIndex - 1 {
				return
			}
			
			//print("DATA : \(AFdata)")
			switch AFdata.result {
				case .success(let data):
					if let data = data as? [String : Any], let songs = data["results"] as? [[String : String]] {
						if songs.isEmpty {
							self.showNoResultsMessage()
						} else {
							for song in songs {
								if let name = song["song_name"], let id = song["id"], let artist = song["artist"], let imageURL = song["imgURL"] {
									let songModel = SongModel(name: name, id: id, artist: artist, imageURL: imageURL)
									newSongResults.append(songModel)
								} else {
									self.showServerErrorMessage()
								}
							}
						}
						self.songResults = newSongResults
						self.tableView.reloadData()
						self.resultSearchController?.searchBar.isLoading = false
					} else {
						self.showServerErrorMessage()
					}
					
				case .failure:
					self.showServerErrorMessage()
			}
			
		}
	}
	
}




extension SearchSongsViewController: UISearchBarDelegate {
	func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
		// something
		return true
	}
}




extension SearchSongsViewController: UIScrollViewDelegate {
	func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
		hideKeyboard()
	}
}

