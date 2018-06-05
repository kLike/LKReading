//
//  ViewController.swift
//  LKReading
//
//  Created by klike on 2018/5/28.
//  Copyright © 2018年 kLike. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func beginReading(_ sender: UIButton) {
        if let urlStr = Bundle.main.path(forResource: "重生西游之齐天大圣", ofType: "txt") {
            let readVc = LKReadViewController()
            readVc.bookUrlStr = urlStr
            present(readVc, animated: true, completion: nil)
        }
        
    }
    
}

