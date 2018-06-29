//
//  LKReadBookManager.swift
//  LKReading
//
//  Created by klike on 2018/5/28.
//  Copyright © 2018年 kLike. All rights reserved.
//

import Foundation
import CoreText
import RealmSwift

class LKBookManager: NSObject {
    
    static func loadBook(bookId: String, completeBack: @escaping (LKReadModel) -> ()) {
        if let readModel = getBook(bookId: bookId) {
            completeBack(readModel)
        } else {
            let readModel = LKReadModel()
            readModel.firstChapterId = "1"
            readModel.bookId = bookId
            readModel.isNetBook = true
            LKBookManager.downloadChapter(bookId: bookId, chapterId: "1") { (chapterModel) in
                completeBack(readModel)
                LKBookManager.loadBookChapter(bookId: bookId, chapterId: chapterModel.lastChapterId)
                LKBookManager.loadBookChapter(bookId: bookId, chapterId: chapterModel.nextChapterId)
            }
        }
    }
 
    static func loadBook(bookUrlStr: String, completeBack: @escaping (LKReadModel, [String: LKReadChapterModel]?) -> ()) {
        guard let bookName = bookUrlStr.components(separatedBy: "/").last?.components(separatedBy: ".").first else {
            print("bookName parsing fail!")
            return
        }
        if let readModel = getBook(bookId: bookName) {
            completeBack(readModel, nil)
        } else {
            LKBookParsing.parsingLocalBook(bookUrlStr: bookUrlStr) { (readModel, chapters) in
                self.saveBookDate(readModel: readModel, chapters: chapters) {
                    DispatchQueue.main.safeAsync {
                        completeBack(readModel, chapters)
                    }
                }
            }
        }
    }
    
    static func loadBookChapter(bookId: String?,
                                chapterId: String?,
                                isNetBook: Bool? = false,
                                lastChapterId: String? = nil,
                                nextChapterId: String? = nil,
                                completeBack: ((LKReadChapterModel) -> ())? = nil) {
        guard let chapterId = chapterId, let bookId = bookId else { return }
        let realm = try! Realm()
        if let chapterModel = realm.object(ofType: LKReadChapterModel.self, forPrimaryKey: bookId + chapterId), chapterModel.content.count > 0 {
            dividChapterContent(chapterModel: chapterModel)
            completeBack?(chapterModel)
        } else {
            if let isNetBook = isNetBook, isNetBook {
                //网络小说
                print("数据库不存在\(bookId)-\(chapterId), 正在下载...")
                //预先存储章节model，不然加载本章的时候 往前翻页因为取不到lastChapterId 而无法回退
                let chapterModel = LKReadChapterModel()
                chapterModel.bookId = bookId
                chapterModel.id = chapterId
                chapterModel.bookChapterId = bookId + chapterId
                chapterModel.lastChapterId = lastChapterId
                chapterModel.nextChapterId = nextChapterId
                try! realm.write {
                    realm.add(chapterModel, update: true)
                }
                downloadChapter(bookId: bookId, chapterId: chapterId) { (chapterModel) in
                    dividChapterContent(chapterModel: chapterModel)
                    completeBack?(chapterModel)
                }
            } else {
                //本地小说
                //wait... 数据库存储完成
            }
        }
    }
    
    //下载章节
    static func downloadChapter(bookId: String, chapterId: String, completeBack: @escaping (LKReadChapterModel) -> ()) {
        //模拟下载章节
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
            let chapterModel = LKReadChapterModel()
            chapterModel.id = chapterId
            chapterModel.lastChapterId = String(Int(chapterId)! - 1)
            chapterModel.nextChapterId = String(Int(chapterId)! + 1)
            chapterModel.content = randomString()
            chapterModel.bookChapterId = bookId + chapterId
            chapterModel.bookId = bookId
            chapterModel.title = "第\(chapterModel.id ?? "")章 网络小说"
            let realm = try! Realm()
            try! realm.write {
                realm.add(chapterModel, update: true)
            }
            completeBack(chapterModel)
        }
    }
    
    //章节分页
    static func dividChapterContent(chapterModel: LKReadChapterModel) {
        if chapterModel.themeVersion != LKReadTheme.share.themeVersion {
            if chapterModel.content.count > 0 {
                let pageContentArr = LKBookManager.divideChapter(content: chapterModel.content)
                let realm = try! Realm()
                try! realm.write {
                    realm.add(chapterModel, update: true)
                    chapterModel.pageContentArr.removeAll()
                    chapterModel.pageContentArr.append(objectsIn: pageContentArr)
                    chapterModel.themeVersion = LKReadTheme.share.themeVersion
                }
            }
        }
    }
    
    static func getBook(bookId: String) -> LKReadModel? {
        let realm = try! Realm()
        return realm.object(ofType: LKReadModel.self, forPrimaryKey: bookId)
    }
    
    static func divideChapter(content: String) -> List<String> {
        let contenNSStr = content as NSString
        let pageStrArr = List<String>()
        let contentAtr = NSMutableAttributedString(string: content, attributes: LKReadTheme.share.getReadTextAttrs())
        let frameSetter = CTFramesetterCreateWithAttributedString(contentAtr as CFAttributedString)
        let path = CGPath(rect: LKReadTheme.share.edgeRect, transform: nil)
        var range = CFRangeMake(0, 0)
        var offset = 0
        while(range.location + range.length < contentAtr.length) {
            let frame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(offset, 0), path, nil)
            range = CTFrameGetVisibleStringRange(frame)
            pageStrArr.append(contenNSStr.substring(with: NSMakeRange(offset, range.length)))
            offset += range.length
        }
        return pageStrArr
    }
    
    static func saveBookDate(readModel: LKReadModel, chapters: [String: LKReadChapterModel], completeBack: @escaping () -> ()) {
        if let readModel = readModel.copy() as? LKReadModel {
            DispatchQueue(label: "background").async {
                autoreleasepool {
                    print("save------------start \(Date())")
                    var chaptersArr = [LKReadChapterModel]()
                    for chapter in chapters.values {
                        chaptersArr.append(chapter.copy() as! LKReadChapterModel)
                    }
                    let realm = try! Realm()
                    try! realm.write {
                        realm.add(readModel, update: true)
                        realm.add(chaptersArr, update: true)
                    }
                    print("save------------over \(Date())")
                    completeBack()
                }
            }
        }
    }
  
}


extension DispatchQueue {
    func safeAsync(_ task: @escaping () -> ()) {
        if self === DispatchQueue.main && Thread.isMainThread {
            task()
        } else {
            async { task() }
        }
    }
}


extension LKBookManager {
    static func randomString() -> String {
        let characters: NSString = "八月的骄阳穿过稀稀疏疏的银杏树叶映入湖中，一阵秋风吹来，湖面上波光粼粼，仿若破碎的星辰闪着点点微光。湖边的一条小路上，一辆不起眼的普通黑漆马车正缓缓地驶过来，须臾间便停在了这棵银杏树下。驾车的是一名看上去约二十多岁的年轻人，精瘦的身躯穿着一套略有些皱巴的绛色长衫，黝黑的脸庞并不出众，但从衣衫的质地来看倒像是京城某位官家的仆从。只见他左右瞧了一眼，见四下里无人这才蹑手蹑脚地靠近车厢，悄悄掀开车前的帘子往里扫了一眼便又马上放下，然后身子往后一靠缓缓地吐出一口气来，嘴里喃喃道：“表姑娘，你可不要怪小的啊，如果小的不将你偷偷弄出来，恐怕小的和老娘的两条命都保不住了！”说完这话，他极快地扫了一眼周围，忙又悄悄地说道：“表姑娘，将来你若是有机会报仇可一定不要找我啊，我跟你说，想要害你的人那可不是别人，正是……"
        var content = ""
        for _ in 0..<(arc4random() % 30) {
            let start = Int(arc4random()) % characters.length
            let len = Int(arc4random()) % (characters.length - start)
            let randomStr = characters.substring(with: NSRange.init(location: Int(start), length: Int(len)))
            content = content.appending("\t")
            content = content.appending(randomStr)
            content = content.appending("\n")
        }
        return content
    }
}




