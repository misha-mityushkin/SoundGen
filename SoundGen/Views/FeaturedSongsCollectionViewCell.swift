//
//  SongPreviewCollectionViewCell.swift
//  SoundGen
//
//  Created by Michael Mityushkin on 2021-05-02.
//

import UIKit

class FeaturedSongsCollectionViewCell: UICollectionViewCell {

	@IBOutlet weak var coverImage: UIImageView!
	@IBOutlet weak var songName: UILabel!
	@IBOutlet weak var artist: UILabel!
	
	override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
