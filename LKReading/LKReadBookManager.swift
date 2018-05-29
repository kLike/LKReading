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
    
    func loadBook(bookUrlStr: String) -> LKReadModel {
        var readModel = LKReadModel()
        do {
            readModel.chapterArr = parsingLocalBook(bookContent: try String.init(contentsOfFile: bookUrlStr, encoding: .utf8))
        } catch { }
        return readModel
    }
    
    func parsingLocalBook(bookContent: String) -> [LKReadChapterModel] {
        let bookContentNSStr = bookContent as NSString
        var chapterArr = [LKReadChapterModel]()
        let pattern = "第[0-9一二三四五六七八九十百千]*[章回].*"
        if let expression = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) {
            let chapterResult = expression.matches(in: bookContent, options: .reportProgress, range: NSMakeRange(0, bookContentNSStr.length))
            chapterResult.enumerated().forEach({ (index, chapterEle) in
                guard index < 50 else {
                    return
                }
                print("解析(\(index)/\(chapterResult.count))...")
                let nextRange = (index == chapterResult.count - 1) ? NSMakeRange(bookContentNSStr.length, 0) : chapterResult[index + 1].range
                var chapterModel = LKReadChapterModel()
                chapterModel.id = String(index)
                chapterModel.title = bookContentNSStr.substring(with: chapterEle.range)
                chapterModel.content = bookContentNSStr.substring(with: NSMakeRange(chapterEle.range.location, nextRange.location))
                chapterModel.lastChapterId = String(index - 1)
                chapterModel.nextChapterId = String(index + 1)
                if index == 0 {
                    if chapterEle.range.location > 0 {
                        var prefaceChapterModel = LKReadChapterModel()
                        prefaceChapterModel.title = "前言"
                        prefaceChapterModel.content = bookContentNSStr.substring(to: chapterEle.range.location)
                        prefaceChapterModel.id = "-1"
                        prefaceChapterModel.nextChapterId = "0"
                        prefaceChapterModel.lastChapterId = "start"
                        if let content = prefaceChapterModel.content {
                           prefaceChapterModel.pageRangeArr = divideChapter(content: content)
                        }
                        chapterArr.append(prefaceChapterModel)
                    } else {
                        chapterModel.lastChapterId = "start"
                    }
                }
                if index == chapterResult.count - 1 {
                    chapterModel.nextChapterId = "end"
                }
                if let content = chapterModel.content {
                    chapterModel.pageRangeArr = divideChapter(content: content)
                }
                chapterArr.append(chapterModel)
            })
        }
        return chapterArr
    }
    
    func divideChapter(content: String) -> [NSRange] {
        var pageRangeArr = [NSRange]()
        let contentAtr = NSMutableAttributedString(string: content, attributes: LKReadTheme.share.getReadTextAttrs())
        let frameSetter = CTFramesetterCreateWithAttributedString(contentAtr as CFAttributedString)
        let path = CGPath(rect: LKReadTheme.share.edgeRect, transform: nil)
        var range = CFRangeMake(0, 0)
        var offset = 0
        while(range.location + range.length < contentAtr.length) {
            let frame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(offset, 0), path, nil)
            range = CTFrameGetVisibleStringRange(frame)
            pageRangeArr.append(NSMakeRange(offset, range.length))
            offset += range.length
        }
        return pageRangeArr
    }
    
}




