//
//  LKReadTheme.swift
//  LKReading
//
//  Created by klike on 2018/5/29.
//  Copyright © 2018年 kLike. All rights reserved.
//

import Foundation
import UIKit

let kScreenW = UIScreen.main.bounds.width
let kScreenH = UIScreen.main.bounds.height
let kStatusBarH = UIApplication.shared.statusBarFrame.size.height
let kNavigationBarH = kStatusBarH + 44

struct LKReadTheme {
    
    static var share = LKReadTheme()
    
    var edgeRect: CGRect = CGRect(x: 15, y: 40, width: kScreenW - 30, height: kScreenH - 40 - 64)
    
    var fontSize: CGFloat = 15 {
        didSet { themeVersion += 1 }
    }
    var lineSpace: CGFloat = 3 {
        didSet { themeVersion += 1 }
    }
    var textColor: UIColor = UIColor.colorFromHex(0x333333)
    
    var themeVersion = 0 //是否需要重新分页的标识
    
    var backImgBackArr = ["bookRead_bg1", "bookRead_bg2", "bookRead_bg3", "bookRead_bg4"]
    var backImgIndex = 0
    
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


