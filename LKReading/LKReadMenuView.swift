//
//  LKReadMenuView.swift
//  LKReading
//
//  Created by klike on 2018/5/31.
//  Copyright © 2018年 kLike. All rights reserved.
//

import UIKit

protocol LKReadMenuViewDelegate {
    func exitReading()
}


class LKReadMenuView: UIView {
    
    var delegate: LKReadMenuViewDelegate?

    @IBOutlet weak var pageBtn1: UIButton!
    @IBOutlet weak var pageBtn2: UIButton!
    @IBOutlet weak var pageBtn3: UIButton!
    @IBOutlet weak var fontLab: UILabel!
    @IBOutlet weak var back1: UIButton!
    @IBOutlet weak var back2: UIButton!
    @IBOutlet weak var back3: UIButton!
    @IBOutlet weak var back4: UIButton!
    @IBOutlet weak var back5: UIButton!
    @IBOutlet weak var back6: UIButton!
    @IBOutlet weak var lightSlider: UISlider!
    @IBOutlet weak var pageStack: UIStackView!
    
    @IBOutlet weak var navViewH: NSLayoutConstraint!
    @IBOutlet weak var setViewH: NSLayoutConstraint!
    @IBOutlet weak var chapterViewH: NSLayoutConstraint!
    @IBOutlet weak var directoriesViewW: NSLayoutConstraint!
    
    @IBOutlet weak var navView: UIView!
    @IBOutlet weak var setView: UIView!
    @IBOutlet weak var chapterView: UIView!
    @IBOutlet weak var directoriesView: UIView!
    
    var showing: Bool = false
    
    override func awakeFromNib() {
        isUserInteractionEnabled = true
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dissmiss)))
        navView.transform = CGAffineTransform(translationX: 0, y: -navViewH.constant)
        setView.transform = CGAffineTransform(translationX: 0, y: setViewH.constant)
        chapterView.transform = CGAffineTransform(translationX: 0, y: chapterViewH.constant)
        directoriesView.transform = CGAffineTransform(translationX: -directoriesViewW.constant, y: 0)
    }
    
    func show() {
        showing = true
        isHidden = false
        backgroundColor = UIColor.clear
        UIView.animate(withDuration: 0.3) {
            self.navView.transform = CGAffineTransform(translationX: 0, y: 0)
            self.chapterView.transform = CGAffineTransform(translationX: 0, y: 0)
        }
    }
    
    @objc func dissmiss() {
        showing = false
        UIView.animate(withDuration: 0.3, animations: {
            self.navView.transform = CGAffineTransform(translationX: 0, y: -self.navViewH.constant)
            self.setView.transform = CGAffineTransform(translationX: 0, y: self.setViewH.constant)
            self.chapterView.transform = CGAffineTransform(translationX: 0, y: self.chapterViewH.constant)
            self.directoriesView.transform = CGAffineTransform(translationX: -self.directoriesViewW.constant, y: 0)
        }) { (_) in
            self.isHidden = true
        }
    }
    
    @IBAction func setViewShow(_ sender: UIButton) {
        UIView.animate(withDuration: 0.3) {
            self.setView.transform = CGAffineTransform(translationX: 0, y: 0)
            self.chapterView.transform = CGAffineTransform(translationX: 0, y: self.chapterViewH.constant)
        }
    }
    
    @IBAction func directoriesViewShow(_ sender: UIButton) {
        UIView.animate(withDuration: 0.3) {
            self.navView.transform = CGAffineTransform(translationX: 0, y: -self.navViewH.constant)
            self.setView.transform = CGAffineTransform(translationX: 0, y: self.setViewH.constant)
            self.chapterView.transform = CGAffineTransform(translationX: 0, y: self.chapterViewH.constant)
            self.directoriesView.transform = CGAffineTransform(translationX: 0, y: 0)
            self.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        }
    }
    
    @IBAction func fontDown(_ sender: UIButton) {
        
    }
    
    @IBAction func fontAdd(_ sender: UIButton) {
        
    }
    
    @IBAction func backgroundChange(_ sender: UIButton) {
        
    }
    
    @IBAction func pageChange(_ sender: UIButton) {
        
    }
    
    @IBAction func exitClick(_ sender: UIButton) {
        delegate?.exitReading()
    }
    
    @IBAction func lightChange(_ sender: UISlider) {
        UIScreen.main.brightness = CGFloat(sender.value)
    }
    
}
