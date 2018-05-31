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
    var page = 0
}

class LKReadViewController: UIViewController {
    
    var bookUrlStr: String?
    var bookModel: LKReadModel?
    var readingPosition = ReadingPosition()
    var pageFlag = 0
    
    lazy var pageViewController: UIPageViewController = {
        let page = UIPageViewController(transitionStyle: .pageCurl, navigationOrientation: .horizontal, options: nil)
        page.isDoubleSided = true
        page.dataSource = self
        page.delegate = self
        addChildViewController(page)
        return page
    }()
    
    lazy var menuView: LKReadMenuView = {
        let mView = Bundle.main.loadNibNamed("LKReadMenuView", owner: nil, options: nil)?.first as! LKReadMenuView
        mView.frame = view.bounds
        mView.delegate = self
        view.addSubview(mView)
        return mView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(pageViewController.view)
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapView(ges:))))
        loadBook()
    }
    
    @objc func tapView(ges: UITapGestureRecognizer) {
        let point = ges.location(in: view)
        if (kScreenW / 4 ... kScreenW / 4 * 3).contains(point.x) && !menuView.showing {
            menuView.show()
        }
    }

    private func loadBook() {
        if let bookUrlStr = bookUrlStr {
            bookModel = LKBookManager().loadBook(bookUrlStr: bookUrlStr)
            let contentVc = LKReadSingleViewController()
            if let firstChapter = bookModel?.chapters?.first?.value {
                contentVc.contentView.content = firstChapter.content ?? "null"
                if let firstChapterId = firstChapter.id {
                    contentVc.position = ReadingPosition(chapterId: firstChapterId, page: 0)
                    readingPosition = contentVc.position
                }
            }
            pageViewController.setViewControllers([contentVc], direction: .forward, animated: true, completion: nil)
        }
    }
    
    private func findNextPage(reviseReadingPosition: Bool) -> String? {
        if let chapterModel = bookModel?.chapters?[readingPosition.chapterId] {
            if readingPosition.page + 1 >= (chapterModel.pageContentArr?.count ?? 0) {
                //某一章最后一页
                guard chapterModel.lastChapterId != "end" else {
                    //最后一章最后一页
                    return nil
                }
                if let nextChapterId = chapterModel.nextChapterId, let nextChapterModel = bookModel?.chapters?[nextChapterId] {
                    if reviseReadingPosition {
                        readingPosition.chapterId = nextChapterModel.id ?? ""
                        readingPosition.page = 0
                        return nextChapterModel.pageContentArr?.first
                    }
                    return chapterModel.pageContentArr?.last
                }
            } else {
                if reviseReadingPosition {
                    readingPosition.chapterId = chapterModel.id ?? ""
                    readingPosition.page += 1
                }
                return chapterModel.pageContentArr?[readingPosition.page]
            }
        }
        return nil
    }
    
    private func findLastPage(reviseReadingPosition: Bool) -> String? {
        if let chapterModel = bookModel?.chapters?[readingPosition.chapterId] {
            if readingPosition.page <= 0 {
                //某一章第一页
                guard chapterModel.lastChapterId != "start" else {
                    //第一章第一页
                    return nil
                }
                if let lastChapterId = chapterModel.lastChapterId, let lastChapterModel = bookModel?.chapters?[lastChapterId] {
                    if reviseReadingPosition {
                        readingPosition.chapterId = lastChapterModel.id ?? ""
                        readingPosition.page = (lastChapterModel.pageContentArr?.count ?? 1) - 1
                    }
                    return lastChapterModel.pageContentArr?.last
                }
            } else {
                if reviseReadingPosition {
                    readingPosition.chapterId = chapterModel.id ?? ""
                    readingPosition.page -= 1
                    return chapterModel.pageContentArr?[readingPosition.page]
                }
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
        pageFlag -= 1
        if pageFlag % 2 == 0 {
            guard let content = findLastPage(reviseReadingPosition: true) else {
                return nil
            }
            let contentVc = LKReadSingleViewController()
            contentVc.contentView.content = content
            contentVc.position = readingPosition
            return contentVc
        }
        guard let content = findLastPage(reviseReadingPosition: false) else {
            return nil
        }
        let contentVc = LKReadSingleViewController()
        contentVc.contentView.content = content
        let rect = contentVc.view.bounds
        UIGraphicsBeginImageContextWithOptions(rect.size, true, 0.0)
        let context = UIGraphicsGetCurrentContext()
        let transform = CGAffineTransform(a: -1.0, b: 0.0, c: 0.0, d: 1.0, tx: rect.size.width, ty: 0.0)
        context?.concatenate(transform)
        contentVc.view.layer.render(in: context!)
        let backImage = UIGraphicsGetImageFromCurrentImageContext()
        let backImgView = UIImageView(frame: contentVc.view.bounds)
        backImgView.image = backImage
        contentVc.view.addSubview(backImgView)
        UIGraphicsEndImageContext()
        return contentVc
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        pageFlag += 1
        if pageFlag % 2 == 0 {
            guard let content = findNextPage(reviseReadingPosition: true) else {
                return nil
            }
            let contentVc = LKReadSingleViewController()
            contentVc.contentView.content = content
            contentVc.position = readingPosition
            return contentVc
        }
        guard let content = findNextPage(reviseReadingPosition: false) else {
            return nil
        }
        let contentVc = LKReadSingleViewController()
        contentVc.contentView.content = content
        let rect = contentVc.view.bounds
        UIGraphicsBeginImageContextWithOptions(rect.size, true, 0.0)
        let context = UIGraphicsGetCurrentContext()
        let transform = CGAffineTransform(a: -1.0, b: 0.0, c: 0.0, d: 1.0, tx: rect.size.width, ty: 0.0)
        context?.concatenate(transform)
        contentVc.view.layer.render(in: context!)
        let backImage = UIGraphicsGetImageFromCurrentImageContext()
        let backImgView = UIImageView(frame: contentVc.view.bounds)
        backImgView.image = backImage
        contentVc.view.addSubview(backImgView)
        UIGraphicsEndImageContext()
        return contentVc
    }
    
}

extension LKReadViewController: UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        if let readingVc = pendingViewControllers.first as? LKReadSingleViewController {
            print("reading --- \(readingVc.position)")
            readingPosition = readingVc.position
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if let readingVc = previousViewControllers.first as? LKReadSingleViewController {
            print("completed(\(completed)) ... \(readingVc.position)")
            if !completed {
                readingPosition = readingVc.position
            }
        }
    }
    
}

extension LKReadViewController: LKReadMenuViewDelegate {
    
    func exitReading() {
        dismiss(animated: true, completion: nil)
    }
    
}
