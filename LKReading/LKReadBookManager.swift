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
 
    func loadBook(bookUrlStr: String,
                  completeBack: @escaping (LKReadModel, [String: LKReadChapterModel]?) -> ()) {
        guard let bookName = bookUrlStr.components(separatedBy: "/").last?.components(separatedBy: ".").first else {
            print("bookName parsing fail!")
            return
        }
        if let readModel = getBook(bookId: bookName) {
            completeBack(readModel, nil)
        } else {
            do {
                let content = try String.init(contentsOfFile: bookUrlStr, encoding: .utf8)
                parsingLocalBook(bookName: bookName, bookContent: content, completeBack: { (readModel, chapters) in
                    DispatchQueue.main.safeAsync {
                        completeBack(readModel, chapters)
                    }
                    self.saveBookDate(readModel: readModel, chapters: chapters)
                })
            } catch { }
        }
    }
    
    func saveBookDate(readModel: LKReadModel, chapters: [String: LKReadChapterModel]) {
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
    
    func parsingLocalBook(bookName: String,
                          bookContent: String,
                          completeBack: @escaping (LKReadModel, [String: LKReadChapterModel]) -> ()) {
        DispatchQueue.global().async {
            let readModel = LKReadModel()
            readModel.bookId = bookName
            let bookContentNSStr = bookContent as NSString
            var chapters = [String: LKReadChapterModel]()
            let pattern = "第[0-9一二三四五六七八九十百千]*[章回].*"
            if let expression = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) {
                let chapterResult = expression.matches(in: bookContent, options: .reportProgress, range: NSMakeRange(0, bookContentNSStr.length))
                chapterResult.enumerated().forEach({ (index, chapterEle) in
                    let nextRange = (index == chapterResult.count - 1) ? NSMakeRange(bookContentNSStr.length, 0) : chapterResult[index + 1].range
                    let chapterModel = LKReadChapterModel()
                    chapterModel.id = String(index)
                    chapterModel.title = bookContentNSStr.substring(with: chapterEle.range)
                    chapterModel.content = bookContentNSStr.substring(with: NSMakeRange(chapterEle.range.location, nextRange.location - chapterEle.range.location))
                    chapterModel.lastChapterId = String(index - 1)
                    chapterModel.nextChapterId = String(index + 1)
                    chapterModel.bookId = bookName
                    chapterModel.bookChapterId = bookName + String(index)
                    if index == 0 {
                        if chapterEle.range.location > 0 {
                            let prefaceChapterModel = LKReadChapterModel()
                            prefaceChapterModel.title = "前言"
                            prefaceChapterModel.content = bookContentNSStr.substring(to: chapterEle.range.location)
                            prefaceChapterModel.id = "-1"
                            prefaceChapterModel.nextChapterId = "0"
                            prefaceChapterModel.lastChapterId = "start"
                            prefaceChapterModel.bookId = bookName
                            prefaceChapterModel.bookChapterId = bookName + "-1"
                            chapters["-1"] = prefaceChapterModel
                            readModel.firstChapterId = "-1"
                        } else {
                            chapterModel.lastChapterId = "start"
                            readModel.firstChapterId = chapterModel.id
                        }
                    }
                    if index == chapterResult.count - 1 {
                        chapterModel.nextChapterId = "end"
                    }
                    chapters[chapterModel.id!] = chapterModel
                })
            }
            completeBack(readModel, chapters)
        }
    }
    
    func divideChapter(content: String) -> List<String> {
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

    func getBook(bookId: String) -> LKReadModel? {
        let realm = try! Realm()
        return realm.object(ofType: LKReadModel.self, forPrimaryKey: bookId)
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




