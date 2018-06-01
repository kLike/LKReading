//
//  LKReadBookManager.swift
//  LKReading
//
//  Created by klike on 2018/5/28.
//  Copyright © 2018年 kLike. All rights reserved.
//

import Foundation
import CoreText

class LKBookManager: NSObject {
 
    func loadBook(bookUrlStr: String,
                  advanceBack: @escaping (LKReadModel) -> (),
                  completeBack: @escaping (LKReadModel) -> ()) {
        do {
            let bookName = bookUrlStr.components(separatedBy: "/").last?.components(separatedBy: ".").first
            let content = try String.init(contentsOfFile: bookUrlStr, encoding: .utf8)
            parsingLocalBook(bookName: bookName, bookContent: content, advanceBack: { (readModel) in
                DispatchQueue.main.safeAsync {
                    advanceBack(readModel)
                }
            }, completeBack: { (readModel) in
                DispatchQueue.main.safeAsync {
                    completeBack(readModel)
                }
            })
        } catch { }
    }
    
    func parsingLocalBook(bookName: String?,
                          bookContent: String,
                          advanceBack: @escaping (LKReadModel) -> (),
                          completeBack: @escaping (LKReadModel) -> ()) {
        DispatchQueue.global().async {
            print("parsingLocalBookStart: \(Date().timeIntervalSince1970)")
            var readModel = LKReadModel()
            readModel.bookId = bookName
            let bookContentNSStr = bookContent as NSString
            var chapterDic = [String: LKReadChapterModel]()
            var directoriesArr = [LKDirectoriesModel]()
            let pattern = "第[0-9一二三四五六七八九十百千]*[章回].*"
            if let expression = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) {
                let chapterResult = expression.matches(in: bookContent, options: .reportProgress, range: NSMakeRange(0, bookContentNSStr.length))
                print("matchEnd: \(Date().timeIntervalSince1970)")
                chapterResult.enumerated().forEach({ (index, chapterEle) in
                    //                print("解析(\(index)/\(chapterResult.count))...")
                    let nextRange = (index == chapterResult.count - 1) ? NSMakeRange(bookContentNSStr.length, 0) : chapterResult[index + 1].range
                    var chapterModel = LKReadChapterModel()
                    chapterModel.id = String(index)
                    chapterModel.title = bookContentNSStr.substring(with: chapterEle.range)
                    chapterModel.content = bookContentNSStr.substring(with: NSMakeRange(chapterEle.range.location, nextRange.location - chapterEle.range.location))
                    chapterModel.lastChapterId = String(index - 1)
                    chapterModel.nextChapterId = String(index + 1)
                    var directoriesModel = LKDirectoriesModel(id: chapterModel.id, title: chapterModel.title)
                    if index == 0 {
                        if chapterEle.range.location > 0 {
                            var prefaceChapterModel = LKReadChapterModel()
                            prefaceChapterModel.title = "前言"
                            prefaceChapterModel.content = bookContentNSStr.substring(to: chapterEle.range.location)
                            prefaceChapterModel.id = "-1"
                            prefaceChapterModel.nextChapterId = "0"
                            prefaceChapterModel.lastChapterId = "start"
                            if let content = prefaceChapterModel.content {
                                prefaceChapterModel.pageContentArr = self.divideChapter(content: content)
                            }
                            chapterDic[prefaceChapterModel.id!] = prefaceChapterModel
                            directoriesModel = LKDirectoriesModel(id: prefaceChapterModel.id, title: prefaceChapterModel.title)
                            directoriesArr.append(directoriesModel)
                        } else {
                            chapterModel.lastChapterId = "start"
                        }
                    }
                    if index == chapterResult.count - 1 {
                        chapterModel.nextChapterId = "end"
                    }
                    if let content = chapterModel.content {
                        chapterModel.pageContentArr = self.divideChapter(content: content)
                    }
                    chapterDic[chapterModel.id!] = chapterModel
                    directoriesArr.append(directoriesModel)
                    if chapterDic.count == 5 {
                        print("divideAdvanceChapterEnd: \(Date().timeIntervalSince1970)")
                        readModel.chapters = chapterDic
                        readModel.chapterTitles = directoriesArr
                        advanceBack(readModel)
                    }
                })
            }
            readModel.chapters = chapterDic
            readModel.chapterTitles = directoriesArr
            completeBack(readModel)
            print("divideChapterAllEnd: \(Date().timeIntervalSince1970)")
        }
    }
    
    func divideChapter(content: String) -> [String] {
        let contenNSStr = content as NSString
        var pageStrArr = [String]()
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




