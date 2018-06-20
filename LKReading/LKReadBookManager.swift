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
 
    static func loadBook(bookUrlStr: String,
                  completeBack: @escaping (LKReadModel, [String: LKReadChapterModel]?) -> ()) {
        guard let bookName = bookUrlStr.components(separatedBy: "/").last?.components(separatedBy: ".").first else {
            print("bookName parsing fail!")
            return
        }
        if let readModel = getBook(bookId: bookName) {
            completeBack(readModel, nil)
        } else {
            LKBookParsing.parsingLocalBook(bookUrlStr: bookUrlStr) { (readModel, chapters) in
                DispatchQueue.main.safeAsync {
                    completeBack(readModel, chapters)
                }
                self.saveBookDate(readModel: readModel, chapters: chapters)
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
    
    static func saveBookDate(readModel: LKReadModel, chapters: [String: LKReadChapterModel]) {
        if let readModel = readModel.copy() as? LKReadModel {
            DispatchQueue(label: "background").async {
                autoreleasepool {
                    var chaptersArr = [LKReadChapterModel]()
                    for chapter in chapters.values {
                        chaptersArr.append(chapter.copy() as! LKReadChapterModel)
                    }
                    let realm = try! Realm()
                    try! realm.write {
                        realm.add(readModel, update: true)
                        realm.add(chaptersArr, update: true)
                    }
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




