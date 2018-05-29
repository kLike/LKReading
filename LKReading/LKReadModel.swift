//
//  LKReadModel.swift
//  LKReading
//
//  Created by klike on 2018/5/28.
//  Copyright © 2018年 kLike. All rights reserved.
//

import Foundation

struct LKReadModel: Codable {
    var bookId: String?
    var chapterArr: [LKReadChapterModel]?
}

struct LKReadChapterModel: Codable {
    var id: String?
    var title: String?
    var content: String?
    var nextChapterId: String?
    var lastChapterId: String?
    var pageRangeArr: [NSRange]?
}
