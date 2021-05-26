//
//  SpotifyOptionsViewController.swift
//  SoundGen
//
//  Created by Michael Mityushkin on 2021-05-14.
//

import UIKit
import Alamofire

class SpotifyOptionsViewController: UIViewController {
	
	@IBOutlet weak var navigationBar: UINavigationBar!
	
	var chooseSongsVC: ChooseSongsViewController?
	var chooseMusicTypeVC: ChooseMusicTypeViewController?
	var fromChooseSongs = true
	
	var codeVerifier: String = ""
	var responseTypeCode: String? {
		didSet {
			fetchSpotifyToken { (dictionary, error) in
				if let error = error {
					print("Fetching token request error \(error)")
					return
				}
				let accessToken = dictionary!["access_token"] as! String
				DispatchQueue.main.async {
					self.appRemote.connectionParameters.accessToken = accessToken
					self.appRemote.connect()
				}
			}
		}
	}
	lazy var appRemote: SPTAppRemote = {
		let appRemote = SPTAppRemote(configuration: configuration, logLevel: .debug)
		appRemote.connectionParameters.accessToken = self.accessToken
		appRemote.delegate = self
		return appRemote
	}()
	var accessToken = UserDefaults.standard.string(forKey: K.Spotify.accessTokenKey) {
		didSet {
			let defaults = UserDefaults.standard
			defaults.set(accessToken, forKey: K.Spotify.accessTokenKey)
		}
	}
	
	lazy var configuration: SPTConfiguration = {
		let configuration = SPTConfiguration(clientID: K.Spotify.spotifyClientId, redirectURL: K.Spotify.redirectUri)
		// Set the playURI to a non-nil value so that Spotify plays music after authenticating and App Remote can connect
		// otherwise another app switch will be required
		configuration.playURI = ""
		// Set these url's to your backend which contains the secret to exchange for an access token
		// You can use the provided ruby script spotify_token_swap.rb for testing purposes
		configuration.tokenSwapURL = URL(string: "http://localhost:1234/swap")
		configuration.tokenRefreshURL = URL(string: "http://localhost:1234/refresh")
		return configuration
	}()
	
	lazy var sessionManager: SPTSessionManager? = {
		let manager = SPTSessionManager(configuration: configuration, delegate: self)
		return manager
	}()
	private var lastPlayerState: SPTAppRemotePlayerState?
	
	

    override func viewDidLoad() {
        super.viewDidLoad()
		view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handleDismiss)))
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		navigationBar.makeTransparent()
	}
	
	func showErrorMessage() {
		Alerts.showNoOptionAlert(title: "An Error Occurred", message: "Please try reselecting your 3 songs", sender: self)
	}
	
	@IBAction func generateOnSpotifyPressed(_ sender: UIButton) {
		
		sessionManager?.initiateSession(with: K.Spotify.scopes, options: .clientOnly)
		
		
		return
		Alerts.showNoOptionAlert(title: "Not Implemented", message: "Please fuck off and try the other option", sender: self)
	}
	
	@IBAction func useOurAccountPressed(_ sender: UIButton) {
		if fromChooseSongs, let chooseSongsVC = chooseSongsVC {
			dismiss(animated: true) {
				chooseSongsVC.generatePlaylist()
			}
		} else if !fromChooseSongs, let chooseMusicTypeVC = chooseMusicTypeVC {
			dismiss(animated: true) {
				chooseMusicTypeVC.generatePlaylist()
			}
		} else {
			showErrorMessage()
		}
	}
	
	
	@IBAction func infoButtonPressed(_ sender: UIBarButtonItem) {
		Alerts.showNoOptionAlert(title: "Spotify Info", message: "Generating the playlist on your Spotify account will allow you to edit and customize it afterwards. Playlists generated on our Spotify account will be erased after 24 hours", sender: self)
	}
	
	@IBAction func backButtonPressed(_ sender: UIBarButtonItem) {
		dismiss(animated: true, completion: nil)
	}
	
	
	var viewTranslation = CGPoint(x: 0, y: 0)
	@objc func handleDismiss(sender: UIPanGestureRecognizer) {
		return
		switch sender.state {
			case .changed:
				viewTranslation = sender.translation(in: view)
				UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
					print("y translation: \(self.viewTranslation.y)")
					self.view.transform = CGAffineTransform(translationX: 0, y: -self.viewTranslation.y)
				})
			case .ended:
				print(self.view.frame.height)
				if viewTranslation.y < view.frame.height / 3 {
					UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
						//self.view.transform = .identity
					})
				} else {
					//dismiss(animated: true, completion: nil)
				}
			default:
				break
		}
	}
	
}





extension SpotifyOptionsViewController {
	
	/// Fetch Spotify access token. Use after getting responseTypeCode
	func fetchSpotifyToken(completion: @escaping ([String: Any]?, Error?) -> Void) {
		let url = URL(string: "https://accounts.spotify.com/api/token")!
		var request = URLRequest(url: url)
		request.httpMethod = "POST"
		let spotifyAuthKey = "Basic \((K.Spotify.spotifyClientId + ":" + K.Spotify.spotifyClientSecretKey).data(using: .utf8)!.base64EncodedString())"
		request.allHTTPHeaderFields = ["Authorization": spotifyAuthKey, "Content-Type": "application/x-www-form-urlencoded"]
		do {
			var requestBodyComponents = URLComponents()
			let scopeAsString = K.Spotify.stringScopes.joined(separator: " ") //put array to string separated by whitespace
			requestBodyComponents.queryItems = [URLQueryItem(name: "client_id", value: K.Spotify.spotifyClientId), URLQueryItem(name: "grant_type", value: "authorization_code"), URLQueryItem(name: "code", value: responseTypeCode!), URLQueryItem(name: "redirect_uri", value: K.Spotify.redirectUri.absoluteString), URLQueryItem(name: "code_verifier", value: codeVerifier), URLQueryItem(name: "scope", value: scopeAsString),]
			request.httpBody = requestBodyComponents.query?.data(using: .utf8)
			let task = URLSession.shared.dataTask(with: request) { data, response, error in
				guard let data = data,                            // is there data
					  let response = response as? HTTPURLResponse,  // is there HTTP response
					  (200 ..< 300) ~= response.statusCode,         // is statusCode 2XX
					  error == nil else {                           // was there no error, otherwise ...
					print("Error fetching token \(error?.localizedDescription ?? "")")
					return completion(nil, error)
				}
				let responseObject = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
				print("Access Token Dictionary=", responseObject ?? "")
				completion(responseObject, nil)
			}
			task.resume()
		} catch {
			print("Error JSON serialization \(error.localizedDescription)")
		}
	}
}




extension SpotifyOptionsViewController: SPTAppRemoteDelegate {
	func appRemoteDidEstablishConnection(_ appRemote: SPTAppRemote) {
		//appRemote.playerAPI?.delegate = self
		appRemote.playerAPI?.subscribe(toPlayerState: { (success, error) in
			if let error = error {
				print("Error subscribing to player state:" + error.localizedDescription)
			}
		})
	}
	
	func appRemote(_ appRemote: SPTAppRemote, didDisconnectWithError error: Error?) {
		lastPlayerState = nil
	}
	
	func appRemote(_ appRemote: SPTAppRemote, didFailConnectionAttemptWithError error: Error?) {
		lastPlayerState = nil
	}
}





extension SpotifyOptionsViewController: SPTSessionManagerDelegate {
	
	func sessionManager(manager: SPTSessionManager, didFailWith error: Error) {
		if error.localizedDescription == "The operation couldn’t be completed. (com.spotify.sdk.login error 1.)" {
			print("AUTHENTICATE with WEBAPI")
		} else {
			print("didFailWithError")
		}
	}
	
	func sessionManager(manager: SPTSessionManager, didRenew session: SPTSession) {
		print("didRenew")
	}
	
	func sessionManager(manager: SPTSessionManager, didInitiate session: SPTSession) {
		appRemote.connectionParameters.accessToken = session.accessToken
		appRemote.connect()
	}
	
}
