//
//  PHealthDetailViewController.swift
//  UPillow
//
//  Created by 吴迪玮 on 2017/8/25.
//  Copyright © 2017年 Podoon. All rights reserved.
//

import UIKit

class PHealthDetailViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension PHealthDetailViewController {
    //MARK: Actions
    
    @IBAction func actionBack(_ sender: Any) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
}
