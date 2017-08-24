//
//  PHealhRecordTableCell.swift
//  UPillow
//
//  Created by 吴迪玮 on 2017/8/23.
//  Copyright © 2017年 Podoon. All rights reserved.
//

import UIKit

class PHealthRecordTableCell: UITableViewCell {
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var startSleepTimeLabel: UILabel!
    @IBOutlet weak var wakeTimeLabel: UILabel!
    
    @IBOutlet weak var sleepDurationLabel: UILabel!
    
    @IBOutlet weak var deepSleepDurationLabel: UILabel!
    
    @IBOutlet weak var shallowSleepDurationLabel: UILabel!
    
    @IBOutlet weak var chartContainerView: UIView!
    
    var charView: PStatusChartView?
    
    static let identifier = "PHealthRecordTableCellIdentifier"

    override func awakeFromNib() {
        super.awakeFromNib()
        self.chartContainerView.layer.cornerRadius = 10
        self.chartContainerView.clipsToBounds = true
        
        let chartView = Bundle.main.loadNibNamed("PStatusChartView", owner: nil, options: nil)?.first! as! PStatusChartView
        chartView.initializeBy(headerHeight: 110,
                               data: PStatusData(startTime: Date.init(),
                                                 duration: 3600,
                                                 statusLabels: ["侧卧","仰卧"],
                                                 statusColors: [Specs.color.insoleRSSILevelGreen,Specs.color.insoleRSSILevelRed],
                                                 items: [0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,0,0,0,0,0,0,1,1,1,1,1,0,0,0,0,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1])
        )
        chartView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width-20, height: chartView.statusViewHeight + 110)
        self.chartContainerView.addSubview(chartView)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        
    }
    
    @IBAction func actionTap(_ sender: UIButton) {
    }
    

}
