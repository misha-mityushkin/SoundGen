//
//  Constants.swift
//  SoundGen
//
//  Created by Michael Mityushkin on 2021-05-02.
//

import UIKit


struct K {
	
	struct Collections {
		
	}
	
	
	struct Identifiers {
		static let featuredSongsCollectionCell = "featuredSongsCollectionCell"
		static let songCell = "songCell"
	}
	
	struct StoryboardIDs {
		static let spotifyOptionsVC = "spotifyOptionsVC"
	}
	
	struct Nibs {
		static let songCellNibName = "SongTableViewCell"
		static let featuredSongsCellNibName = "FeaturedSongsCollectionViewCell"
	}
	
	struct Segues {
		static let mainScreenToChooseSongs = "mainScreenToChooseSongs"
		static let mainScreenToChooseMusicType = "mainScreenToChooseMusicType"
		static let chooseSongsToSearch = "chooseSongsToSearch"
		static let chooseSongsToPlaylistResults = "chooseSongsToPlaylistResults"
		static let chooseMusicTypeToPlaylistResults = "chooseMusicTypeToPlaylistResults"
	}
	
	struct Strings {
		static let dateFormatString = "yyyy-MM-dd"
	}
	
	struct ColorNames {
		static let goldColor = "goldColor"
		static let goldColorInverseMoreContrast = "goldColorInverseMoreContrast"
		static let otherButtonColor = "otherButtonColor"
		static let placeholderTextColor = "placeholderTextColor"
		static let spotifyColor = "spotifyColor"
		static let darkGrayColor = "darkGray"
		static let lightGrayColor = "lightGray"
	}
	
	struct Colors {
		static let goldColor = UIColor(named: ColorNames.goldColor)
		static let goldColorInverseMoreContrast = UIColor(named: ColorNames.goldColorInverseMoreContrast)
		static let otherButtonColor = UIColor(named: ColorNames.otherButtonColor)
		static let placeholderTextColor = UIColor(named: ColorNames.placeholderTextColor)
		static let spotifyColor = UIColor(named: ColorNames.spotifyColor)
		static let darkGrayColor = UIColor(named: ColorNames.darkGrayColor)
		static let lightGrayColor = UIColor(named: ColorNames.lightGrayColor)
	}
	
	struct ImageNames {
		static let chevronRight = "chevron.right"
		static let backgroundNoLogo = "background"
		static let placeholderPhoto = "photo"
		static let searchIcon = "magnifyingglass"
	}
	
	struct Images {
		static let placeholderPhoto = UIImage(systemName: ImageNames.placeholderPhoto)
		static let searchIcon = UIImage(systemName: ImageNames.searchIcon)
	}
	
	
	
	struct Spotify {
		static let accessTokenKey = "access-token-key"
		static let redirectUri = URL(string:"SoundGen://")!
		static let spotifyClientId = "57880f905c6141ff99ef9d1c40e074a0"
		static let spotifyClientSecretKey = "9d0174511e4b4315bbd4ccdbf3903970"
		/*
		Scopes let you specify exactly what types of data your application wants to access, and the set of scopes you pass in your call determines what access permissions the user is asked to grant. For more information, see https://developer.spotify.com/web-api/using-scopes/.
		*/
		//remove scopes you don't need
		static let scopes: SPTScope = [.userReadEmail, .userReadPrivate,
								.userReadPlaybackState, .userModifyPlaybackState,
								.userReadCurrentlyPlaying, .streaming, .appRemoteControl,
								.playlistReadCollaborative, .playlistModifyPublic, .playlistReadPrivate, .playlistModifyPrivate,
								.userLibraryModify, .userLibraryRead,
								.userTopRead, .userReadPlaybackState, .userReadCurrentlyPlaying,
								.userFollowRead, .userFollowModify,]
		//remove scopes you don't need
		static let stringScopes = ["user-read-email", "user-read-private",
							"user-read-playback-state", "user-modify-playback-state", "user-read-currently-playing",
							"streaming", "app-remote-control",
							"playlist-read-collaborative", "playlist-modify-public", "playlist-read-private", "playlist-modify-private",
							"user-library-modify", "user-library-read",
							"user-top-read", "user-read-playback-position", "user-read-recently-played",
							"user-follow-read", "user-follow-modify",]
	}
	
	
}
