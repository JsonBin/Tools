//
//  ViewController.swift
//  WBExtension
//
//  Created by zwb on 17/2/8.
//  Copyright © 2017年 HengSu Technology. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        let btn=UIButton(type: .system)
        
        btn.wb.setImageWithURL("", forState: .normal)
        
        // 点击时间间隔
        btn.customEventInterval=10
        
        // kvo
        btn.wb_addObserverBlockForKeyPath("key") { (obj, old, new) in
            
        }
        
        // notification
        wb_addNotificationForName("notification") { (noti) in
            
        }
        
        _=btn.ve.width
        
        
        _=checkLibrary
        
        _=WB_RGB(2, g: 2, b: 2)
        
        UIColor.wb_rgb(1, g: 1, b: 1)
        
        Date.stringWithTimeInterval(200)
        
        PayManager.shared.wb_payWithOrderMsg("") { (code, error) in
            if code == .success{
                
            }
            if code == .cancle{
                
            }
        }
        
        let image = UIImage.wb_imageNamed("")
        
        image!.wb_cornerRadius(10, imageWidth: 10, model: .aspectFit)
        
        let s=WBBarButtomItem(title: "", style: .plain, target: nil, action: nil)
        s.isEnabled=false
        
        s.run.containProperty("adfadsf")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
