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
    var chapterId: String?
    var chapterTitle: String?
}
