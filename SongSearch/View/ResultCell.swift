//
//  ResultCell.swift
//  SongSearch
//
//  Created by seonho Kim on 2020/12/30.
//  Copyright © 2020 comfunny. All rights reserved.
//

import UIKit

class ResultCell: UITableViewCell {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var artistName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(track: Track) {
        title.text = track.title
        artistName.text = track.artistName
    }
}
