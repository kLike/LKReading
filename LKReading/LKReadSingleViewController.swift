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
        loadingView.stopAnimating()
        loadingView.removeFromSuperview()
        return contentView
    }()
    
    lazy var backImg: UIImageView = {
        let iv = UIImageView(frame: view.bounds)
        view.addSubview(iv)
        view.sendSubview(toBack: iv)
        return iv
    }()
    
    lazy var chapterTitleLabel: UILabel = {
        let lab = UILabel(frame: CGRect(x: 15, y: kStatusBarH - 15, width: kScreenW - 30, height: 20))
        lab.textColor = UIColor.colorFromHex(0x999999)
        lab.font = UIFont.systemFont(ofSize: 12)
        view.addSubview(lab)
        return lab
    }()
    
    var loadingView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    
    convenience init(content: String? = nil, position: ReadingPosition? = nil, chapterTitle: String? = nil) {
        self.init()
        if let content = content {
            self.contentView.content = content
        }
        if let position = position {
            self.position = position
        }
        if let title = chapterTitle {
            self.chapterTitleLabel.text = title
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        renewBackImg()
        loadingView.center = view.center
        loadingView.startAnimating()
        view.addSubview(loadingView)
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
