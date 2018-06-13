//
//  LKReadModel.swift
//  LKReading
//
//  Created by klike on 2018/5/28.
//  Copyright © 2018年 kLike. All rights reserved.
//

import Foundation
import RealmSwift

class LKReadModel: Object, NSCopying {
    @objc dynamic var bookId: String?
//    @objc dynamic var chapters = [String: LKReadChapterModel]()
//    @objc dynamic var chapterTitles = [LKDirectoriesModel]()
    @objc dynamic var readingPosition: ReadingPosition? = nil
//    let chapters = List<LKReadChapterModel>()
    @objc dynamic var firstChapterId: String?
    
    override class func primaryKey() -> String? {
        return "bookId"
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        let model = LKReadModel()
        model.bookId = bookId
        model.readingPosition = readingPosition
        model.firstChapterId = firstChapterId
        return model
    }
}

class LKReadChapterModel: Object, NSCopying {
    @objc dynamic var bookChapterId: String? //作为章节唯一标识 bookId + id
    @objc dynamic var bookId: String?
    @objc dynamic var id: String?
    @objc dynamic var title = ""
    @objc dynamic var content = ""
    @objc dynamic var nextChapterId: String?
    @objc dynamic var lastChapterId: String?
    var pageContentArr = List<String>()
    @objc dynamic var themeVersion: Int = -1
    
    override class func primaryKey() -> String? {
        return "bookChapterId"
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        let model = LKReadChapterModel()
        model.bookChapterId = bookChapterId
        model.id = id
        model.content = content
        for pageContent in pageContentArr {
            model.pageContentArr.append(pageContent)
        }
        model.bookId = bookId
        model.nextChapterId = nextChapterId
        model.lastChapterId = lastChapterId
        model.title = title
        model.themeVersion = themeVersion
        return model
    }
}

class LKDirectoriesModel: Object {
    @objc dynamic var id: String?
    @objc dynamic var title = ""
    
    convenience init(id: String?, title: String) {
        self.init()
        self.id = id
        self.title = title
    }
}

class ReadingPosition: Object {
    @objc dynamic var chapterId = "0"
    @objc dynamic var page = 0
    
    convenience init(chapterId: String = "0", page: Int = 0) {
        self.init()
        self.chapterId = chapterId
        self.page = page
    }
}

