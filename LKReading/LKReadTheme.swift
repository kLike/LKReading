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

struct LKReadTheme {
    
    static let share = LKReadTheme()
    
    var edgeRect: CGRect = CGRect(x: 15, y: 40, width: kScreenW - 30, height: kScreenH - 40 - 64)
    
    var fontSize: CGFloat = 15
    var textColor: UIColor = UIColor.black
    var lineSpace: CGFloat = 3
    
    func getReadTextAttrs() -> [NSAttributedStringKey : Any] {
        let para = NSMutableParagraphStyle()
        para.lineSpacing = lineSpace
        return [NSAttributedStringKey.paragraphStyle: para,
                NSAttributedStringKey.font: UIFont.systemFont(ofSize: fontSize),
                NSAttributedStringKey.foregroundColor: textColor]
    }
    
}


