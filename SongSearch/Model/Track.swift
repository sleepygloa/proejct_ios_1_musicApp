//
//  Track.swift
//  SongSearch
//
//  Created by joonwon lee on 02/04/2019.
//  Copyright © 2019 joonwon.lee. All rights reserved.
//

import UIKit

struct Response: Codable {
    let resultCount: Int
    let results: [Track]
}

struct Track: Codable {
    let title: String
    let artistName: String
    let thumbnail: String
    let previewUrl: String
    
    enum CodingKeys: String, CodingKey {
        case title = "trackName"
        case artistName = "artistName"
        case thumbnail = "artworkUrl30"
        case previewUrl = "previewUrl"
    }
}
