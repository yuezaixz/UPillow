//
//  PSettingViewController.swift
//  UPillow
//
//  Created by 吴迪玮 on 2017/8/9.
//  Copyright © 2017年 Podoon. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
import SafariServices

class PSettingViewController: UIViewController {
    
    fileprivate typealias RowModel = Dictionary<String, String>
    
    fileprivate struct Keys {
        static let Section = "section"
        static let Rows = "rows"
        static let Title = "title"
        static let Link = "link"
        static let Id = "id"
        
        static let TODO = "TODO"
    }
    
    @IBOutlet weak var settingTableView: UITableView!
    
    /// Datasource
    fileprivate let data = [
        [
            Keys.Section: Localized(key: "Guide"),
            Keys.Rows: [
                [Keys.Title: Localized(key: "Video")],
                [Keys.Title: Localized(key: "Website"), Keys.Link: "http://podoon.com"]
            ]
        ],
        [
            Keys.Section: Localized(key: "Settings"),
            Keys.Rows: [
                [Keys.Title: Keys.TODO],
            ]
        ],
        [
            Keys.Section: Localized(key: "Feedback"),
            Keys.Rows: [
                [Keys.Title: Localized(key: "Email"), Keys.Id: "david@podoon.cn", Keys.Link: "mailto:david@podoon.cn"]
            ]
        ],
        [
            Keys.Section: Localized(key: "Misc"),
            Keys.Rows: [
                [Keys.Title: Localized(key: "Rate"), Keys.Link: "https://itunes.apple.com/app/id1213677528"]
            ]
        ]
    ]
    
    /// Static cells
    fileprivate struct NonreusableCells {
        static let hideCompletedCell = SwitchSettingCell(
            title: "TODO",
            identifier: "HideCell",
            on: false
        )
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        settingTableView.register(BaseSettingCell.self, forCellReuseIdentifier: BaseSettingCell.identifier)
        
        title = Bundle.main.name
        
    }
    
    fileprivate func rows(at section: Int) -> Array<Any> {
        return data[section][Keys.Rows] as! Array<Any>
    }
    
    fileprivate func rowModel(at indexPath: IndexPath) -> RowModel {
        return rows(at: indexPath.section)[indexPath.row] as! RowModel
    }
    
    
    //MARK:other
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}

// MARK: - TableView
extension PSettingViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return data[section][Keys.Section] as? String
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rows(at: section).count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = rowModel(at: indexPath)
        guard let title = model[Keys.Title] else { return UITableViewCell() }
//        if title == Keys.HideCompleted {
//            return NonreusableCells.hideCompletedCell
//        } else if title == Keys.Record {
//            return RecordCells.hideCompletedCell
//        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: BaseSettingCell.identifier, for: indexPath)
            cell.textLabel?.text = title
            cell.detailTextLabel?.text = model[Keys.Id]
            cell.accessoryType = .none
            return cell
//        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let model = rowModel(at: indexPath)
        guard let title = model[Keys.Title] else { return }
        
        // Open guide video
        if title == Localized(key: "Video") {
            if let url = Bundle.main.url(forResource: "demo", withExtension: "mp4") {
                let playerVC = AVPlayerViewController()
                playerVC.player = AVPlayer(url: url)
                present(playerVC, animated: true) {
                    playerVC.player?.play()
                }
            }
        }
//        else if title == Keys.ReminderList {
//            navigationController?.pushViewController(HiddenTypeVC(), animated: true)
//        } else if title == Keys.DefaultCalendar {
//            navigationController?.pushViewController(DefaultTypeVC(), animated: true)
//        } else if title == Keys.FetchingLimitation {
//            navigationController?.pushViewController(FetchBoundsVC(), animated: true)
//        }
        else {
            // Open URL
            guard let link = model[Keys.Link] else { return }
            guard let url = URL(string: link) else { return }
            
            // SafariViewController only support HTTP protocol
            if link.hasPrefix("http") {
                let safari = SFSafariViewController(url: url)
                safari.preferredControlTintColor = Specs.color.tint
                present(safari, animated: true)
            } else {
                UIApplication.shared.open(url, options: [:])
            }
        }
    }
    
    func tableView(_ tableView: UITableView, shouldShowMenuForRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, canPerformAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return action == #selector(copy(_:))
    }
    
    // MARK: - Copy action
    func tableView(_ tableView: UITableView, performAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) {
        guard let link = rowModel(at: indexPath)[Keys.Link] else { return }
        UIPasteboard.general.string = link
    }
}


