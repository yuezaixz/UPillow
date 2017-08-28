//
//  PHealthDetailViewController.swift
//  UPillow
//
//  Created by 吴迪玮 on 2017/8/25.
//  Copyright © 2017年 Podoon. All rights reserved.
//

import UIKit

class PHealthDetailViewController: UIViewController {
    
    @IBOutlet weak var settingPillowButton: UIButton! {
        didSet {
            settingPillowButton.layer.borderWidth = 2.0
            settingPillowButton.layer.borderColor = Specs.color.orange.cgColor
        }
    }
    
    @IBOutlet weak var sleepTimeLabel: UILabel!
    @IBOutlet weak var sleepStartTimeLabel: UILabel!
    @IBOutlet weak var wakeTimeLabel: UILabel!
    @IBOutlet weak var deepSleepTimeLabel: UILabel!
    @IBOutlet weak var shallowSleepTimeLabel: UILabel!
    @IBOutlet weak var sideSleepPercentLabel: UILabel!
    @IBOutlet weak var lieSleepPercentLabel: UILabel!
    @IBOutlet weak var sleepQualityLabel: UILabel!
    @IBOutlet weak var adviceLabel: UILabel!
    
    @IBOutlet weak var sleepPoseView: UIView!
    @IBOutlet weak var sleepQualityView: UIView!
    
    @IBOutlet weak var sleepPoseViewHeight: NSLayoutConstraint!
    @IBOutlet weak var sleepQualityViewHeight: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //TODO 测试代码
        do {
            let chartView = Bundle.main.loadNibNamed("PStatusChartView", owner: nil, options: nil)?.first! as! PStatusChartView
            chartView.initializeBy(headerHeight: 50,
                                   data: PStatusData(startTime: Date.init(),
                                                     duration: 3600,
                                                     statusLabels: ["侧卧","仰卧"],
                                                     statusColors: [Specs.color.insoleRSSILevelGreen,Specs.color.insoleRSSILevelRed],
                                                     items: [0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,0,0,0,0,0,0,1,1,1,1,1,0,0,0,0,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1])
            )
            chartView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width-20, height: chartView.statusViewHeight + 50)
            self.sleepPoseViewHeight.constant = chartView.statusViewHeight + 70
            self.sleepPoseView.insertSubview(chartView, at: 0)
        }
        do {
            let chartView = Bundle.main.loadNibNamed("PStatusChartView", owner: nil, options: nil)?.first! as! PStatusChartView
            chartView.initializeBy(headerHeight: 50,
                                   data: PStatusData(startTime: Date.init(),
                                                     duration: 3600,
                                                     statusLabels: ["深睡","潜睡"],
                                                     statusColors: [Specs.color.insoleRSSILevelGreen,Specs.color.insoleRSSILevelRed],
                                                     items: [0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,0,0,0,0,0,0,1,1,1,1,1,0,0,0,0,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1])
            )
            chartView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width-20, height: chartView.statusViewHeight + 50)
            self.sleepQualityViewHeight.constant = chartView.statusViewHeight + 70
            self.sleepQualityView.insertSubview(chartView, at: 0)
        }
    }
    
    //MARK: Others

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension PHealthDetailViewController {
    //MARK: Actions
    
    @IBAction func actionBack(_ sender: Any) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
}
