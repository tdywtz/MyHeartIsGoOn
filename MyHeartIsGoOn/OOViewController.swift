//
//  OOViewController.swift
//  MyHeartIsGoOn
//
//  Created by bangong on 16/6/23.
//  Copyright © 2016年 auto. All rights reserved.
//

import UIKit

class OOViewController: UIViewController {

    internal var label: CZWLabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
   self.view.backgroundColor = UIColor.whiteColor()
//        // Do any additional setup after loading the view.
//        let label = LHLabel.init(frame: CGRectMake(100, 100, 100, 100))
//        self.view.addSubview(label)
        
        label = CZWLabel.init(frame: CGRectMake(100, 100, 100, 100))
        label.text = "kashdgfiad\nasdfljdklagjhiegrhasldkjgfadgij\nasidhfdaklhg"
        self.view.addSubview(label)
        label.addImage(UIImage.init(named: "钱") , size: CGSizeMake(60, 60), range: label.rangeOfString("ash"))
        
        
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
