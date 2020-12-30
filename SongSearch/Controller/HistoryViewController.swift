//
//  HistoryViewController.swift
//  SongSearch
//
//  Created by seonho Kim on 2020/12/30.
//  Copyright © 2020 comfunny. All rights reserved.
//
import UIKit

protocol CellSelecting {
    func searchHistoryDidSelect(of keyword: String)
    func watchHistoryDidSelect(of track: Track)
}


class HistoryViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    let sectionTitles: [String] = ["Recent", "Loved"]
    var delegate: CellSelecting?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nib = UINib(nibName: "HeaderView", bundle: Bundle.main)
        tableView.register(nib, forHeaderFooterViewReuseIdentifier: "header")
        
        
        FirebaseManager.shared.fetchSearchHistory {
            self.tableView.reloadData()
        }
        
        FirebaseManager.shared.fetchWatchHistory {
            self.tableView.reloadData()
        }
    }
    
}

extension HistoryViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionTitles.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return FirebaseManager.shared.searchHistory.count
        } else {
            return FirebaseManager.shared.watchHistory.count
        }
    }
    
//    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        return sectionTitles[section]
//    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header") as? HeaderView
        headerView?.title.text = sectionTitles[section]
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 65
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? HistoryCell else {
            return UITableViewCell()
        }
        
        if indexPath.section == 0 {
            // search data
            cell.historyLabel.text = FirebaseManager.shared.searchHistory[indexPath.row]
        } else {
            // watch data
            let track = FirebaseManager.shared.watchHistory[indexPath.row]
            cell.historyLabel.text = track.title
        }
        return cell
    }
}

extension HistoryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            // search history  > 검색을 수행
            let keyword = FirebaseManager.shared.searchHistory[indexPath.row]
            delegate?.searchHistoryDidSelect(of: keyword)
        } else {
            // watch history > 재생을 시킴
            let track = FirebaseManager.shared.watchHistory[indexPath.row]
            delegate?.watchHistoryDidSelect(of: track)
        }
    }
}
