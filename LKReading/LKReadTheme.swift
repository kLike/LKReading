//
//  LKReadTheme.swift
//  LKReading
//
//  Created by klike on 2018/5/29.
//  Copyright © 2018年 kLike. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

let kScreenW = UIScreen.main.bounds.width
let kScreenH = UIScreen.main.bounds.height
let kStatusBarH = UIApplication.shared.statusBarFrame.size.height
let kNavigationBarH = kStatusBarH + 44
let kBottomSafeH: CGFloat = kNavigationBarH > 64 ? 34 : 0.01

struct LKReadTheme {
    
    static var share = LKReadTheme()
    
    var edgeRect: CGRect = CGRect(x: 15, y: 40, width: kScreenW - 30, height: kScreenH - 40 - 64)
    
    var fontSize: CGFloat = 15 {
        didSet { 
            UserDefaults.standard.set(fontSize, forKey: "readingFontSize")
            themeVersion += 1
        }
    }
    var lineSpace: CGFloat = 5 {
        didSet {
            UserDefaults.standard.set(lineSpace, forKey: "readingLineSpace")
            themeVersion += 1
        }
    }
    var textColor: UIColor = UIColor.colorFromHex(0x333333)
    
    //是否需要重新分页的标识
    var themeVersion = 0 {
        didSet {
            UserDefaults.standard.set(themeVersion, forKey: "readingThemeVersion")
        }
    }
    
    var backImgBackArr = ["bookRead_bg1", "bookRead_bg2", "bookRead_bg3", "bookRead_bg4"]
    var backImgIndex = 0 {
        didSet {
            UserDefaults.standard.set(backImgIndex, forKey: "readingBackImgIndex")
        }
    }
    
    var transitionStyleIndex = 0 {
        didSet {
            UserDefaults.standard.set(transitionStyleIndex, forKey: "readingTransitionStyleIndex")
        }
    }
    
    init() {
        if let fontSize = UserDefaults.standard.object(forKey: "readingFontSize") as? CGFloat {
            self.fontSize = fontSize
        }
        if let lineSpace = UserDefaults.standard.object(forKey: "readingLineSpace") as? CGFloat {
            self.lineSpace = lineSpace
        }
        if let themeVersion = UserDefaults.standard.object(forKey: "readingThemeVersion") as? Int {
            self.themeVersion = themeVersion
        }
        if let backImgIndex = UserDefaults.standard.object(forKey: "readingBackImgIndex") as? Int {
            self.backImgIndex = backImgIndex
        }
        if let transitionStyleIndex = UserDefaults.standard.object(forKey: "readingTransitionStyleIndex") as? Int {
            self.transitionStyleIndex = transitionStyleIndex
        }
    }
    
    func getReadTextAttrs() -> [NSAttributedStringKey : Any] {
        let para = NSMutableParagraphStyle()
        para.lineSpacing = lineSpace
        return [NSAttributedStringKey.paragraphStyle: para,
                NSAttributedStringKey.font: UIFont.systemFont(ofSize: fontSize),
                NSAttributedStringKey.foregroundColor: textColor]
    }
    
    func getBackImg() -> UIImage? {
        return UIImage(named: backImgBackArr[backImgIndex])
    }
    
}

extension UIColor {
    
    static func rgb(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat) -> UIColor {
        return UIColor.init(red: r / 255,
                            green: g / 255,
                            blue: b / 255,
                            alpha: 1.0)
    }
    
    static func colorFromHex(_ Hex: UInt32) -> UIColor {
        return UIColor.init(red: CGFloat((Hex & 0xFF0000) >> 16) / 255.0,
                            green: CGFloat((Hex & 0xFF00) >> 8) / 255.0,
                            blue: CGFloat((Hex & 0xFF)) / 255.0,
                            alpha: 1.0)
    }
    
}


