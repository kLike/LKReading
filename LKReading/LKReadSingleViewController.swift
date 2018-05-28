//
//  LKReadSingleViewController.swift
//  LKReading
//
//  Created by klike on 2018/5/28.
//  Copyright © 2018年 kLike. All rights reserved.
//

import UIKit

class LKReadSingleViewController: UIViewController {
    
    let content = [
        "黑暗中，他钳住她的下巴，“告诉我，你叫什么名字？”\n她手指紧紧攥住床单，自轻自贱：“知道名字又如何？你只要一分不少的把钱打到我卡上就行了。”\n      \n豪门一夜，她失身于他；\n一个为钱，一个为欲 。\n本以为拿到钱就可以拍拍屁股走人，当一切没有发生 。\n谁知那古怪男人从此却阴魂不散的缠住了她 。\n      \n传闻，那个男人富可敌国，但面目丑陋，人人敬而远之 ；\n传闻，那个男人势力庞大，但身份神秘，无人知道他的来历 ；\n传闻，那个男人情妇众多 ， 却极度仇恨女人，以玩弄女人为乐 ；\n      \n她被逼入绝境，痛苦哀求，“魔鬼，求你放了我……” \n他却冷冷一笑，死死将她压在身下 ，“你走可以，孩子留下！” \n孩子？她有个熊孩子！\n某人邪魅一笑，得寸进尺：“马上就有了……”\n———————— \n\n看到【右上角的❤】木有？【点击收藏】瘦十斤哦！↑↑↑↑↑ \n",
        "   亲爹和小三合伙害死母亲，还卖给人渣你要怎么办？\n   关键时刻，高富帅带着一纸合约从天而降。\n   辛晴怒视眼前的男人。原本以为是白马王子，结果是个恶魔。\n   “不许走，你只能嫁给我！”他恶狠狠的对想要离开的女人说。\n   辛晴冷笑：“你不是为了祖训才留下我的吗？我只是你的工具。”\n   “谁说的？”男人满眼深情：“你是我孩子的妈！”\n\n   如有雷同，纯属巧合，请勿与现实对号入座。  \n\n  ",
        "    她是数一数二的顶级杀手，谁知被小阿姨下套，将她扔给了陌生男，结果怀上了宝宝。\n    当她想要追问小阿姨孩子的父亲是谁时，小阿姨脚底抹油跑了……六年后，宝宝阴差阳错的被黑夜帝国的人抓走。\n    无奈之下，她只有女扮男装假装成司机潜伏入黑夜帝国老大身边做卧底……\n    \n    每天保底二更。\n\n\n    "
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        let index = Int(arc4random() % 3)
        let contentView = LKReadSingleView(frame: view.bounds)
        contentView.content = content[index]
        view.addSubview(contentView)
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
                let attributedString = NSMutableAttributedString(string: content, attributes: nil)
                let framesetter = CTFramesetterCreateWithAttributedString(attributedString)
                let path = CGPath(rect: CGRect.init(x: 15, y: 100, width: bounds.size.width - 30, height: bounds.size.height - 200), transform: nil)
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
