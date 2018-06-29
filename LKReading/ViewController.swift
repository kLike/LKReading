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
        if let bookName = sender.titleLabel?.text?.components(separatedBy: ".").first,
           let bookType = sender.titleLabel?.text?.components(separatedBy: ".").last,
           let urlStr = Bundle.main.path(forResource: bookName, ofType: bookType) {
            //本地小说
            let readVc = LKReadViewController()
            readVc.bookUrlStr = urlStr
            present(readVc, animated: true, completion: nil)
        } else {
            //网络小说(模拟)
            let readVc = LKReadViewController()
            readVc.bookId = "netBook"
            present(readVc, animated: true, completion: nil)
        }
    }
    
}

