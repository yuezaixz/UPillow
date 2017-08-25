//
//  PHealthRecordViewController.swift
//  UPillow
//
//  Created by 吴迪玮 on 2017/8/18.
//  Copyright © 2017年 Podoon. All rights reserved.
//

import UIKit
import JHPullToRefreshKit

class PHealthRecordViewController: UIViewController {

    @IBOutlet weak var leftArrowImageView: UIImageView!
    @IBOutlet weak var rightArrowImageView: UIImageView!
    @IBOutlet weak var monthSelectCollectView: UICollectionView!
    
    @IBOutlet weak var monthSelectViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var recordTableView: UITableView!
    
    var currentMonthIndex = -1
    
    var monthItems:[String] = ["03月","04月","05月","06月","07月","08月"]//TODO 测试用
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //绘制左右箭头
        self.leftArrowImageView.image = PImageDrawUtil.imageOfLeftArrow
        self.rightArrowImageView.image = PImageDrawUtil.imageOfRightArrow
        monthSelectCollectView.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        
        recordTableView.tableFooterView = UIView.init()
//        self.yahoo = [[YahooRefreshControl alloc] initWithType:JHRefreshControlTypeSlideDown];
        if let myRefreshControl = PRecordRefreshControl.init(type: .slideDown) {
            myRefreshControl.add(to: recordTableView) {
                performAfterDelay(sec: 2, handler: {
                    myRefreshControl.endRefreshing()
                })
            }
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if currentMonthIndex == -1 {
            currentMonthIndex = monthItems.count - 1
            monthSelectCollectView.contentOffset = CGPoint(x: monthSelectCollectView.contentSize.width - UIScreen.main.bounds.size.width + 10, y: 0)//因为edge left inset 为10
        }
    }

    // MARK: - other
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

extension PHealthRecordViewController:UICollectionViewDelegate,UICollectionViewDataSource {
    
    // MARK: - Collection View
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return monthItems.count;
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MonthSelectCollectViewCell.identifier, for: indexPath) as! MonthSelectCollectViewCell
        cell.monthLabel.text = monthItems[indexPath.row]
        cell.monthLabel.textColor = indexPath.row == currentMonthIndex ? Specs.color.orange : Specs.color.white
        return cell;
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(monthItems[indexPath.row])
        currentMonthIndex = indexPath.row
        collectionView.reloadData()
    }
    
}

extension PHealthRecordViewController:UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:PHealthRecordTableCell = recordTableView.dequeueReusableCell(withIdentifier: PHealthRecordTableCell.identifier, for: indexPath) as! PHealthRecordTableCell
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 240.cgFloat
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if self.recordTableView.contentOffset.y <= 150 && self.recordTableView.contentOffset.y > 0 {
            self.monthSelectViewHeightConstraint.constant = 70 - self.recordTableView.contentOffset.y/3
        }
    }
}

class MonthSelectCollectViewCell:UICollectionViewCell {
    
    @IBOutlet weak var monthLabel: UILabel!
    static let identifier = "MonthSelectCollectViewCell"
    
}
