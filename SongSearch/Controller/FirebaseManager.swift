//
//  FirebaseManager.swift
//  SongSearch
//
//  Created by seonho Kim on 2020/12/30.
//  Copyright © 2020 comfunny. All rights reserved.
//
import UIKit
import Firebase

class FirebaseManager {
    
    static let shared: FirebaseManager = FirebaseManager()
    
    var searchHistory: [String] = [] {
        didSet {
            print("---> \(searchHistory)")
        }
    }
    var watchHistory: [Track] = [] {
        didSet {
            print("---> \(watchHistory)")
        }
    }
    
    init() {
    }
    
    // Server 로 데이터 보내기
    func addSearchHistory(keyword: String) {
        searchHistory.insert(keyword, at: 0)
        let rootRef = Database.database().reference()
        rootRef.child("searchHistory").setValue(searchHistory)
    }
    
    func addWatchHistory(track: Track) {
        watchHistory.insert(track, at: 0)
        let tracks: [[String: Any]] = watchHistory.map { $0.toDictionary }
        let rootRef = Database.database().reference()
        rootRef.child("watchHistory").setValue(tracks)
    }

    // Server 에서 데이터 받기
    func fetchSearchHistory(completion: @escaping () -> Void) {
        let rootRef = Database.database().reference()
        rootRef.child("searchHistory").queryLimited(toFirst: 3).observeSingleEvent(of: .value) { snapshot in
            guard let searchHistory = snapshot.value as? [String] else {
                return
            }
            self.searchHistory = searchHistory
            completion()
        }
    }
    
    func fetchWatchHistory(completion: @escaping () -> Void) {
        let rootRef = Database.database().reference()
        rootRef.child("watchHistory").queryLimited(toFirst: 3).observeSingleEvent(of: .value) { snapshot in
            do {
                let data = try JSONSerialization.data(withJSONObject: snapshot.value as Any, options: [])
                let tracks = try JSONDecoder().decode([Track].self, from: data)
                self.watchHistory = tracks
                completion()
            } catch let error {
                print("---> err: \(error.localizedDescription)")
            }
        }
    }
}
