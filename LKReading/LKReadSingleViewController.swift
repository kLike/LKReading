//
//  LKReadSingleViewController.swift
//  LKReading
//
//  Created by klike on 2018/5/28.
//  Copyright © 2018年 kLike. All rights reserved.
//

import UIKit

class LKReadSingleViewController: UIViewController {
    
    lazy var contentView: LKReadSingleView = {
        let contentView = LKReadSingleView(frame: view.bounds)
        view.addSubview(contentView)
        return contentView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.orange
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
