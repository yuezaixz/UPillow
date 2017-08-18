//
//  PHealthRecordViewController.swift
//  UPillow
//
//  Created by 吴迪玮 on 2017/8/18.
//  Copyright © 2017年 Podoon. All rights reserved.
//

import UIKit

class PHealthRecordViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource {

    @IBOutlet weak var leftArrowImageView: UIImageView!
    @IBOutlet weak var rightArrowImageView: UIImageView!
    @IBOutlet weak var monthSelectCollectView: UICollectionView!
    
    var currentMonthIndex = -1
    
    var monthItems:[String] = ["03月","04月","05月","06月","07月","08月"]//TODO 测试用
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //绘制左右箭头
        self.leftArrowImageView.image = PImageDrawUtil.imageOfLeftArrow
        self.rightArrowImageView.image = PImageDrawUtil.imageOfRightArrow
        monthSelectCollectView.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
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

    // MARK: - other
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

class MonthSelectCollectViewCell:UICollectionViewCell {
    
    @IBOutlet weak var monthLabel: UILabel!
    static let identifier = "MonthSelectCollectViewCell"
    
}
