//
//  LKReadSingleViewController.swift
//  LKReading
//
//  Created by klike on 2018/5/28.
//  Copyright © 2018年 kLike. All rights reserved.
//

import UIKit

class LKReadSingleViewController: UIViewController {
    
    var position = ReadingPosition()
    
    lazy var contentView: LKReadSingleView = {
        let contentView = LKReadSingleView(frame: view.bounds)
        view.addSubview(contentView)
        return contentView
    }()
    
    lazy var backImg: UIImageView = {
        let iv = UIImageView(frame: view.bounds)
        view.addSubview(iv)
        view.sendSubview(toBack: iv)
        return iv
    }()
    
    convenience init(content: String?, position: ReadingPosition? = nil) {
        self.init()
        if let content = content {
            self.contentView.content = content
        }
        if let position = position {
            self.position = position
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        renewBackImg()
    }
    
    func renewBackImg() {
        backImg.image = LKReadTheme.share.getBackImg()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

class LKReadSingleView: UIView {
    
    var frameRef: CTFrame?
    
    var content: String? {
        didSet {
            if let content = self.content {
                let attributedString = NSMutableAttributedString(string: content, attributes: LKReadTheme.share.getReadTextAttrs())
                let framesetter = CTFramesetterCreateWithAttributedString(attributedString)
                let path = CGPath(rect: LKReadTheme.share.edgeRect, transform: nil)
                frameRef = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, nil)
                setNeedsDisplay()
            }
        }
    }
    
    override func draw(_ rect: CGRect) {
        if let ctx = UIGraphicsGetCurrentContext(), let frameRef = frameRef {
            ctx.textMatrix = CGAffineTransform.identity
            ctx.translateBy(x: 0, y: bounds.size.height)
            ctx.scaleBy(x: 1.0, y: -1.0)
            CTFrameDraw(frameRef, ctx)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
