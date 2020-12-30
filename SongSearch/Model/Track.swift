//
//  Track.swift
//  SongSearch
//
//  Created by seonho Kim on 2020/12/30.
//  Copyright © 2020 comfunny. All rights reserved.
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
    let previewUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case title = "trackName"
        case artistName = "artistName"
        case thumbnail = "artworkUrl30"
        case previewUrl = "previewUrl"
    }
    
    var toDictionary: [String: Any] {
        let dict: [String: Any] = ["trackName": title, "artistName": artistName, "artworkUrl30": thumbnail, "previewUrl": previewUrl as Any]
        return dict
    }
}
