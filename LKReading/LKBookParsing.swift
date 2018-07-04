//
//  LKBookParsing.swift
//  LKReading
//
//  Created by klike on 2018/6/20.
//  Copyright © 2018年 kLike. All rights reserved.
//

import UIKit
import Zip
import RealmSwift

class LKBookParsing: NSObject {
    
    static func parsingLocalBook(bookUrlStr: String,
                                 completeBack: @escaping (LKReadModel, [String: LKReadChapterModel]) -> ()) {
        let filePath = URL.init(fileURLWithPath: bookUrlStr)
        let bookName = filePath.deletingPathExtension().lastPathComponent
        let bookType = filePath.pathExtension
        if bookType == "txt" {
            do {
                let content = try String.init(contentsOfFile: bookUrlStr, encoding: .utf8)
                LKBookParsing.parseTxtBook(bookName: bookName, bookContent: content, completeBack: { (readModel, chapters) in
                    completeBack(readModel, chapters)
                })
            } catch { }
        }
        else if bookType == "epub" {
            LKBookParsing.parseEpubBook(path: bookUrlStr) { (readModel, chapters) in
                completeBack(readModel, chapters)
            }
        }
        else {
            print("小说格式不支持")
        }
    }
    
    static func parseTxtBook(bookName: String,
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
    
    static func parseEpubBook(path: String, parseBack: @escaping ((LKReadModel, [String: LKReadChapterModel]) -> Swift.Void)) {
        let filePath = URL.init(fileURLWithPath: path)
        let bookName = filePath.deletingPathExtension().lastPathComponent
        let readModel = LKReadModel()
        readModel.bookId = bookName
        DispatchQueue.global().async {
            unzipFile(path: path, bookName: bookName) { (urlStr) in
                if let eUrlStr = epubPathToOpfPath(ePath: urlStr) {
                    parseOpfFile(path: eUrlStr, bookId: bookName, parseBack: { (readModel, chapters) in
                        DispatchQueue.main.safeAsync {
                            parseBack(readModel, chapters)
                        }
                    })
                }
            }
        }
    }
    
    static func unzipFile(path: String, bookName: String, fileOutputHandler: @escaping ((String) -> Swift.Void)) {
        do {
            let filePath = URL.init(fileURLWithPath: path)
            let documentsDirectory = FileManager.default.urls(for:.documentDirectory, in: .userDomainMask)[0]
            let unzipFilePath = documentsDirectory.absoluteString + "\(bookName)"
            Zip.addCustomFileExtension(filePath.pathExtension)
            try Zip.unzipFile(filePath, destination: URL.init(fileURLWithPath: unzipFilePath), overwrite: true, password: nil, progress: { progress in
                print("unzipFileProgress.... \(progress)")
                if progress == 1 {
                    fileOutputHandler(unzipFilePath.replacingOccurrences(of: "file://", with: ""))
                }
            })
        }
        catch {
            print("unzipFile went wrong")
        }
    }
    
    static func epubPathToOpfPath(ePath: String) -> String? {
        let containerPath = ePath + "/META-INF/container.xml"
        guard FileManager.default.fileExists(atPath: containerPath) else {
            print("ERROR: ePub not Valid")
            return nil
        }
        do {
            let document = try CXMLDocument(contentsOf: URL.init(fileURLWithPath: containerPath), options: 0)
            let opfPathArr = try document.nodes(forXPath: "//@full-path")
            if let opfPath = opfPathArr.last as? CXMLNode{
                return ePath + "/" + opfPath.stringValue()
            }
        } catch {
            print("epubPathToOpfPath went wrong")
        }
        return nil
    }
    
    static func parseOpfFile(path: String, bookId: String, parseBack: @escaping ((LKReadModel, [String: LKReadChapterModel]) -> Swift.Void)) {
        do {
            let document = try CXMLDocument(contentsOf: URL.init(fileURLWithPath: path), options: 0)
            let itemsArr = try document.nodes(forXPath: "//opf:item", namespaceMappings: ["opf": "http://www.idpf.org/2007/opf"])
            var ncxFile = ""
            var itemsDic = [String : String]()
            if let itemsArr = itemsArr as? [CXMLElement] {
                itemsArr.forEach({ (element) in
                    itemsDic[element.attribute(forName: "id").stringValue()] = element.attribute(forName: "href").stringValue()
                    if element.attribute(forName: "media-type").stringValue() == "application/x-dtbncx+xml" {
                        ncxFile = element.attribute(forName: "href").stringValue()
                    }
                })
                let pathUrl = URL.init(fileURLWithPath: path)
                let ncxDocument = try CXMLDocument(contentsOf: pathUrl.deletingLastPathComponent().appendingPathComponent(ncxFile), options: 0)
                var titleDic = [String : String]()
                itemsArr.forEach({ (element) in
                    let href = element.attribute(forName: "href").stringValue()
                    var xPath = "//ncx:content[@src='\(href ?? "")']/../ncx:navLabel/ncx:text"
                    do {
                        let ncxNamespaceMappings = ["ncx": "http://www.daisy.org/z3986/2005/ncx/"]
                        var navPoints = try ncxDocument.nodes(forXPath: xPath, namespaceMappings: ncxNamespaceMappings)
                        if navPoints.count == 0 {
                            let contentsArr = try ncxDocument.nodes(forXPath: "//ncx:content", namespaceMappings: ncxNamespaceMappings)
                            if let contentsArr = contentsArr as? [CXMLElement] {
                                contentsArr.forEach({ (element) in
                                    if element.attribute(forName: "src").stringValue().hasPrefix(href ?? "") {
                                        xPath = "//ncx:content[@src='\(element.attribute(forName: "src").stringValue())']/../ncx:navLabel/ncx:text"
                                        do {
                                            navPoints = try ncxDocument.nodes(forXPath: xPath, namespaceMappings: ncxNamespaceMappings)
                                            return
                                        } catch {
                                            print("parseOpfFile went wrong")
                                        }
                                    }
                                })
                            }
                        }
                        if navPoints.count > 0 {
                            if let titleEle = navPoints.first as? CXMLElement, let href = href {
                                titleDic[href] = titleEle.stringValue()
                            }
                        }
                    } catch {
                        print("parseOpfFile went wrong")
                    }
                })
                let itemRefsArr = try document.nodes(forXPath: "//opf:itemref", namespaceMappings: ["opf": "http://www.idpf.org/2007/opf"])
                if let itemRefsArr = itemRefsArr as? [CXMLElement] {
                    let readModel = LKReadModel()
                    readModel.bookId = bookId
                    var chapters = [String: LKReadChapterModel]()
                    itemRefsArr.enumerated().forEach({ (index, element) in
                        if let idref = element.attribute(forName: "idref").stringValue(), let chapHref = itemsDic[idref] {
                            let model = LKReadChapterModel()
                            model.title = titleDic[chapHref] ?? ""
                            model.bookId = bookId
                            model.id = String(index)
                            model.bookChapterId = (model.bookId ?? "") + model.id!
                            do {
                                let conData = try Data.init(contentsOf: pathUrl.deletingLastPathComponent().appendingPathComponent(chapHref))
                                let html = String.init(data: conData, encoding: String.Encoding.utf8)
                                model.content = html?.convertingHTMLToPlainText() ?? ""
                            } catch { }
                            model.lastChapterId = String(index - 1)
                            model.nextChapterId = String(index + 1)
                            if index == 0 {
                                model.lastChapterId = "start"
                                readModel.firstChapterId = model.id
                            }
                            if index == itemRefsArr.count - 1 {
                                model.nextChapterId = "end"
                            }
                            chapters[model.id!] = model
                        }
                    })
                    parseBack(readModel, chapters)
                }
            }
        } catch {
            print("parseOpfFile went wrong")
        }
    }
    
}
