//
//  SearchViewController.swift
//  SongSearch
//
//  Created by seonho Kim on 2020/12/30.
//  Copyright © 2020 comfunny. All rights reserved.
//

import UIKit
import AVKit

class SearchViewController: UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var tracks: [Track] = []

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? HistoryViewController {
            print("---> 맞다.. 여기가 히스토리다.. ")
            vc.delegate = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.isHidden = true
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func dismissKeyboard() {
        searchBar.resignFirstResponder()
    }
}

extension SearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tracks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? ResultCell else {
            return UITableViewCell()
        }
        
        cell.configure(track: tracks[indexPath.row])
        return cell
    }
}

extension SearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismissKeyboard()
        let track = tracks[indexPath.row]
        play(track: track)
        FirebaseManager.shared.addWatchHistory(track: track)
    }
    
    func play(track: Track) {
        // TODO: Play Song
        guard let urlPath = track.previewUrl, let previewUrl = URL(string: urlPath) else { return }
        let playerViewController = AVPlayerViewController()
        present(playerViewController, animated: true, completion: nil)
        let player = AVPlayer(url: previewUrl)
        playerViewController.player = player
        player.play()
    }
}


extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        dismissKeyboard()
        // TODO: Search Code
        guard let searchText = searchBar.text, searchText.isEmpty == false else {
            tableView.isHidden = true
            return
        }
        tableView.isHidden = false
        search(keyword: searchText)
        FirebaseManager.shared.addSearchHistory(keyword: searchText)
    }
    
    func search(keyword: String) {
        
        var urlComponents = URLComponents(string: "https://itunes.apple.com/search?media=music&entity=musicVideo")!
        let queryItem = URLQueryItem(name: "term", value: keyword)
        urlComponents.queryItems?.append(queryItem)
        
        
        guard let requestURL = urlComponents.url else { return }
        URLSession.shared.dataTask(with: requestURL) { [weak self] (data, response, error) in
            guard let strongSelf = self else { return }
            
            // Client-side Error
            guard error == nil else { return }
            
            // Server-side Error
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode else { return }
            let successRange = 200..<300
            
            guard successRange.contains(statusCode) else {
                // serverside error handle
                return
            }
            
            guard let resultData = data else { return }
            strongSelf.tracks = strongSelf.parse(data: resultData) ?? []
            DispatchQueue.main.async {
                strongSelf.tableView.isHidden = false
                strongSelf.tableView.reloadData()
                strongSelf.tableView.setContentOffset(CGPoint.zero, animated: false)
            }
        }.resume()
    }
    
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
}

extension SearchViewController {
    func parse(data: Data) -> [Track]? {
        // TODO: Parse Track From Data
        do {
            let decoder = JSONDecoder()
            let response = try decoder.decode(Response.self, from: data)
            let trackList = response.results
            return trackList
        } catch let error {
            print("---> error:\(error.localizedDescription)")
            return nil
        }
    }
}


extension SearchViewController: CellSelecting {
    func searchHistoryDidSelect(of keyword: String) {
        print("---> 그래?? 키워드 뭔데?? :\(keyword)")
        search(keyword: keyword)
    }
    
    func watchHistoryDidSelect(of track: Track) {
        print("---> 그래?? 트랙이 뭔데?? :\(track.title)")
        play(track: track)
    }
}

