//
//  PlaylistResultsViewController.swift
//  SoundGen
//
//  Created by Michael Mityushkin on 2021-05-02.
//

import UIKit

class PlaylistResultsViewController: UIViewController {

	@IBOutlet weak var navigationBar: UINavigationBar!
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var featuredSongsCollectionView: UICollectionView!
	
	var featuredSongs: [SongModel?] = []
	var playlistLink: URL?
	var playlistName: String?
	
	var openedInSpotify = false
	
	override func viewDidLoad() {
        super.viewDidLoad()
		titleLabel.text = playlistName ?? "Playlist Results"
		featuredSongsCollectionView.register(UINib(nibName: K.Nibs.featuredSongsCellNibName, bundle: nil), forCellWithReuseIdentifier: K.Identifiers.featuredSongsCollectionCell)
		isModalInPresentation = true
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		navigationBar.makeTransparent()
	}
	
	@IBAction func openInSpotifyPressed(_ sender: UIButton) {
		if let url = playlistLink {
			UIApplication.shared.open(url, options: [:], completionHandler: nil)
			openedInSpotify = true
		} else {
			Alerts.showNoOptionAlert(title: "An Error Occurred", message: "We were unable to open the link in Spotify", sender: self)
		}
	}
	
	@IBAction func makeNewPlaylistPressed(_ sender: UIButton) {
		if openedInSpotify {
			goToMainMenu()
		} else {
			Alerts.showTwoOptionAlertDestructive(title: "Wait Up!", message: "You haven't opened your new playlist in Spotify. Are you sure you want to exit?", sender: self, option1: "Exit", option2: "Stay", is1Destructive: true, is2Destructive: false, handler1: { (_) in
				self.goToMainMenu()
			}, handler2: nil)
		}
	}
	
	func goToMainMenu() {
		presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
	}
	
	@IBAction func backButtonPressed(_ sender: UIBarButtonItem) {
		Alerts.showTwoOptionAlertDestructive(title: "Are you sure you want to go back?", message: "You will not be able to return to this page", sender: self, option1: "Exit", option2: "Stay", is1Destructive: true, is2Destructive: false, handler1: { (_) in
			self.dismiss(animated: true, completion: nil)
		}, handler2: nil)
	}
	
}




extension PlaylistResultsViewController: UICollectionViewDataSource, UICollectionViewDelegate {
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return featuredSongs.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: K.Identifiers.featuredSongsCollectionCell, for: indexPath) as! FeaturedSongsCollectionViewCell
		if let song = featuredSongs[indexPath.row] {
			cell.songName.text = song.name
			cell.artist.text = song.artist
			cell.coverImage.load(url: URL(string: song.imageURL)!)
		}
		return cell
	}
	
}




extension PlaylistResultsViewController: UIScrollViewDelegate {
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



