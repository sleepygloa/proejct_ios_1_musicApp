//
//  SearchViewController.swift
//  SongSearch
//
//  Created by joonwon lee on 02/04/2019.
//  Copyright © 2019 joonwon.lee. All rights reserved.
//

import UIKit
import AVKit

class SearchViewController: UIViewController {
    //UI 매핑
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    //테이블 목록
    var tracks: [Track] = []

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func dismissKeyboard() {
        searchBar.resignFirstResponder()
    }
}

extension SearchViewController: UITableViewDataSource {
    //테이블 목록 수
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
        // TODO: Play Song
        guard let previewUrl = URL(string: tracks[indexPath.row].previewUrl) else { return }
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
        guard let searchText = searchBar.text, searchText.isEmpty == false else { return }
        
        //URL세팅
        var urlComponents = URLComponents(string: "https://itunes.apple.com/search?media=music&entity=musicVideo")! //URL
        let queryItem = URLQueryItem(name: "term", value: searchText)
        urlComponents.queryItems?.append(queryItem)
        
        
        //동기처리
        guard let requestURL = urlComponents.url else { return }
        URLSession.shared.dataTask(with: requestURL) { [weak self] (data, response, error) in
            //체크로직 1
            guard let strongSelf = self else { return }
            
            //체크로직 2
            // Client-side Error
            guard error == nil else { return }
            
            //체크로직 3
            // Server-side Error
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode else { return }
            let successRange = 200..<300
            
            //통신 에러처리
            guard successRange.contains(statusCode) else {
                // serverside error handle
                return
            }
            
            guard let resultData = data else { return }
            strongSelf.tracks = strongSelf.parse(data: resultData) ?? []
            DispatchQueue.main.async {
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


