//
//  SongSearchResultsTableViewCell.swift
//  SoundGen
//
//  Created by Michael Mityushkin on 2021-05-03.
//

import UIKit

class SongTableViewCell: UITableViewCell {

	@IBOutlet weak var songName: UILabel!
	@IBOutlet weak var artistName: UILabel!
	@IBOutlet weak var coverImage: UIImageView!
	
	override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
