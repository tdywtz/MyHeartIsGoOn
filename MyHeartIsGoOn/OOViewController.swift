//
//  OOViewController.swift
//  MyHeartIsGoOn
//
//  Created by bangong on 16/6/23.
//  Copyright © 2016年 auto. All rights reserved.
//

import UIKit

class OOViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
   
        // Do any additional setup after loading the view.
        let label = LHLabel.init(frame: CGRectMake(100, 100, 100, 100))
        label.
        self.view.addSubview(label)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
