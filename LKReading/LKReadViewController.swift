//
//  LKReadViewController.swift
//  LKReading
//
//  Created by klike on 2018/5/28.
//  Copyright © 2018年 kLike. All rights reserved.
//

import UIKit

struct ReadingPosition {
    var chapterId = "0"
    var page = 1
}

class LKReadViewController: UIViewController {
    
    var bookModel: LKReadModel?
    var readingPosition = ReadingPosition()
    
    lazy var pageViewController: UIPageViewController = {
        let page = UIPageViewController(transitionStyle: .pageCurl, navigationOrientation: .horizontal, options: nil)
//        page.isDoubleSided = true
        page.dataSource = self
        page.delegate = self
        addChildViewController(page)
        let contentVc = LKReadSingleViewController()
        if let firstChapter = bookModel?.chapters?.first?.value {
            contentVc.contentView.content = firstChapter.content ?? "null"
            if let firstChapterId = firstChapter.id {
                readingPosition.chapterId = firstChapterId
            }
        }
        page.setViewControllers([contentVc], direction: .forward, animated: true, completion: nil)
        return page
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(pageViewController.view)
    }
    
    private func findNextPage() -> String? {
        if let chapterModel = bookModel?.chapters?[readingPosition.chapterId] {
            if readingPosition.page == chapterModel.pageContentArr?.count {
                //某一章最后一页
                guard chapterModel.lastChapterId != "end" else {
                    //最后一章最后一页
                    return nil
                }
                if let nextChapterModel = bookModel?.chapters?[chapterModel.lastChapterId!] {
                    readingPosition.chapterId = nextChapterModel.id ?? ""
                    readingPosition.page = 1
                    return nextChapterModel.pageContentArr?.first
                }
            } else {
                readingPosition.chapterId = chapterModel.id ?? ""
                readingPosition.page += 1
                return chapterModel.pageContentArr?[readingPosition.page + 1]
            }
        }
        return nil
    }
    
    private func findLastPage() -> String? {
        if let chapterModel = bookModel?.chapters?[readingPosition.chapterId] {
            if readingPosition.page == 1 {
                //某一章第一页
                guard chapterModel.lastChapterId != "start" else {
                    //第一章第一页
                    return nil
                }
                if let lastChapterModel = bookModel?.chapters?[chapterModel.nextChapterId!] {
                    readingPosition.chapterId = lastChapterModel.id ?? ""
                    readingPosition.page = lastChapterModel.pageContentArr?.count ?? 1
                    return lastChapterModel.pageContentArr?.last
                }
            } else {
                readingPosition.chapterId = chapterModel.id ?? ""
                readingPosition.page -= 1
                return chapterModel.pageContentArr?[readingPosition.page - 1]
            }
        }
        return nil
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension LKReadViewController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let content = findLastPage() else {
            return nil
        }
        let contentVc = LKReadSingleViewController()
        contentVc.contentView.content = content
        contentVc.position = readingPosition
        return contentVc
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let content = findNextPage() else {
            return nil
        }
        let contentVc = LKReadSingleViewController()
        contentVc.contentView.content = content
        contentVc.position = readingPosition
        return contentVc
    }
    
}

extension LKReadViewController: UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        if let readingVc = pendingViewControllers.first as? LKReadSingleViewController {
            print("reading --- \(readingVc.position)")
//            readingPosition = readingVc.position
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed, let readingVc = previousViewControllers.first as? LKReadSingleViewController {
//            print("reading ... \(readingVc.position)")
        }
    }
    
}
