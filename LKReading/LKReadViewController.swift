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

enum LKTransitionStyle {
    case pageCurl
    case scroll
    case none
}

class LKReadViewController: UIViewController {
    
    var bookUrlStr: String?
    var bookModel: LKReadModel?
    var isReverseSide = false
    var transitionStyle: LKTransitionStyle = .pageCurl
    
    var readingVc = LKReadSingleViewController()
    var readingPosition: ReadingPosition {
        return readingVc.position
    }
    
    var pageViewController: UIPageViewController?
    
    lazy var menuView: LKReadMenuView = {
        let mView = Bundle.main.loadNibNamed("LKReadMenuView", owner: nil, options: nil)?.first as! LKReadMenuView
        mView.frame = view.bounds
        mView.bookNameLab.text = bookModel?.bookId
        mView.delegate = self
        if let chapterTitles = bookModel?.chapterTitles {
            mView.titlesArr = chapterTitles
        }
        view.addSubview(mView)
        mView.isHidden = true
        return mView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initUI()
        
        let showMenuTap = UITapGestureRecognizer(target: self, action: #selector(tapView(ges:)))
        showMenuTap.delegate = self
        view.addGestureRecognizer(showMenuTap)
        
        loadBook()
    }

    func initUI() {
        readingVc.view.removeFromSuperview()
        readingVc.removeFromParentViewController()
        if transitionStyle == .none {
            pageViewController?.view.removeFromSuperview()
            pageViewController?.removeFromParentViewController()
            addChildViewController(readingVc)
            view.addSubview(readingVc.view)
        } else {
            var style: UIPageViewControllerTransitionStyle = .pageCurl
            if transitionStyle == .scroll {
                style = .scroll
            }
            pageViewController = UIPageViewController(transitionStyle: style, navigationOrientation: .horizontal, options: nil)
            if let pageViewController = pageViewController {
                pageViewController.isDoubleSided = true
                pageViewController.dataSource = self
                pageViewController.delegate = self
                addChildViewController(pageViewController)
                pageViewController.setViewControllers([readingVc], direction: .forward, animated: true, completion: nil)
                view.addSubview(pageViewController.view)
            }
        }
        view.bringSubview(toFront: menuView)
        readChapter(chapterId: readingPosition.chapterId, page: readingPosition.page)
    }
    
    @objc func tapView(ges: UITapGestureRecognizer) {
        let point = ges.location(in: view)
        if !menuView.showing {
            if (kScreenW / 4 ... kScreenW / 4 * 3).contains(point.x) {
                if let pageCount = bookModel?.chapters?[readingPosition.chapterId]?.pageContentArr?.count {
                    menuView.pageSlider.value = Float(readingPosition.page) / Float(pageCount - 1)
                }
                menuView.scrollToReadingChapter(chapterId: readingPosition.chapterId)
                menuView.show()
            } else {
                if transitionStyle == .none {
                    let readVc: LKReadSingleViewController?
                    if (0 ... kScreenW / 4).contains(point.x) {
                        readVc = findLastPage()
                    } else {
                        readVc = findNextPage()
                    }
                    if let readVc = readVc {
                        readingVc.contentView.content = readVc.contentView.content
                        readingVc.position = readVc.position
                    }
                }
            }
        }
    }

    private func loadBook() {
        if let bookUrlStr = bookUrlStr {
            LKBookManager().loadBook(bookUrlStr: bookUrlStr) { (readModel) in
                self.bookModel = readModel
                if let firstChapterId = readModel.chapterTitles?.first?.id {
                    self.dividChapterContent(chapterId: firstChapterId)
                    self.readChapter(chapterId: firstChapterId)
                }
                if let chapterTitles = self.bookModel?.chapterTitles {
                    self.menuView.titlesArr = chapterTitles
                }
            }
        }
    }
    
    private func readChapter(chapterId: String? = nil, page: Int = 0) {
        guard let chapterId = chapterId else {
            print("章节不存在...")
            return
        }
        dividChapterContent(chapterId: chapterId)
        if let chapterContent = bookModel?.chapters?[chapterId]?.pageContentArr?[page] {
            readingVc.contentView.content = chapterContent
            readingVc.position = ReadingPosition(chapterId: chapterId, page: page)
            isReverseSide = false
            menuView.scrollToReadingChapter(chapterId: readingPosition.chapterId)
        }
    }
    
    func dividChapterContent(chapterId: String) {
        if let chapterModel = bookModel?.chapters?[chapterId] {
            if chapterModel.themeVersion != LKReadTheme.share.themeVersion {
                if let chapterContent = chapterModel.content {
                    let pageContentArr = LKBookManager().divideChapter(content: chapterContent)
                    bookModel?.chapters?[chapterId]?.pageContentArr = pageContentArr
                    bookModel?.chapters?[chapterId]?.themeVersion = LKReadTheme.share.themeVersion
                }
            }
        }
    }
    
    private func findNextPage() -> LKReadSingleViewController? {
        guard let chapterModel = bookModel?.chapters?[readingPosition.chapterId] else {
            return nil
        }
        if transitionStyle == .pageCurl && isReverseSide {
            //背面
            let contentVc = LKReadSingleViewController(content: chapterModel.pageContentArr?[readingPosition.page])
            return reversalCotentVc(originalVc: contentVc)
        }
        if readingPosition.page + 1 >= (chapterModel.pageContentArr?.count ?? 0) {
            //某一章最后一页
            guard chapterModel.lastChapterId != "end" else {
                //最后一章最后一页
                isReverseSide = false
                return nil
            }
            //下一章
            guard let nextChapterId = chapterModel.nextChapterId else {
                return nil
            }
            dividChapterContent(chapterId: nextChapterId)
            guard let nextChapterModel = bookModel?.chapters?[nextChapterId],
                  let nextContent = nextChapterModel.pageContentArr?.first else {
                return nil
            }
            return LKReadSingleViewController(content: nextContent,
                                              position: ReadingPosition(chapterId: nextChapterModel.id ?? "", page: 0))
        } else {
            return LKReadSingleViewController(content: chapterModel.pageContentArr?[readingPosition.page + 1],
                                              position: ReadingPosition(chapterId: chapterModel.id ?? "", page: readingPosition.page + 1))
        }
    }
    
    private func findLastPage() -> LKReadSingleViewController? {
        if let chapterModel = bookModel?.chapters?[readingPosition.chapterId] {
            let contentVc: LKReadSingleViewController
            if readingPosition.page <= 0 {
                //某一章第一页
                guard chapterModel.lastChapterId != "start" else {
                    //第一章第一页
                    isReverseSide = false
                    return nil
                }
                //上一章
                guard let lastChapterId = chapterModel.lastChapterId else {
                    return nil
                }
                dividChapterContent(chapterId: lastChapterId)
                guard let lastChapterModel = bookModel?.chapters?[lastChapterId],
                      let lastContent = lastChapterModel.pageContentArr?.last else {
                    return nil
                }
                contentVc = LKReadSingleViewController(content: lastContent,
                                                       position: ReadingPosition(chapterId: lastChapterModel.id ?? "",
                                                                                 page: (lastChapterModel.pageContentArr?.count ?? 1) - 1))
                
            } else {
                contentVc = LKReadSingleViewController(content: chapterModel.pageContentArr?[readingPosition.page - 1],
                                                       position: ReadingPosition(chapterId: chapterModel.id ?? "",
                                                                                 page: readingPosition.page - 1))
            }
            if transitionStyle == .pageCurl && isReverseSide {
                return reversalCotentVc(originalVc: contentVc)
            }
            return contentVc
        }
        return nil
    }
    
    //阅读页背面显示，翻转
    private func reversalCotentVc(originalVc: LKReadSingleViewController) -> LKReadSingleViewController {
        let rect = originalVc.view.bounds
        UIGraphicsBeginImageContextWithOptions(rect.size, true, 0.0)
        let context = UIGraphicsGetCurrentContext()
        let transform = CGAffineTransform(a: -1.0, b: 0.0, c: 0.0, d: 1.0, tx: rect.size.width, ty: 0.0)
        context?.concatenate(transform)
        originalVc.view.layer.render(in: context!)
        let backImage = UIGraphicsGetImageFromCurrentImageContext()
        let backImgView = UIImageView(frame: originalVc.view.bounds)
        backImgView.image = backImage
        originalVc.view.addSubview(backImgView)
        UIGraphicsEndImageContext()
        return originalVc
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    deinit {
        print("deinit")
    }
    
}

extension LKReadViewController: UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        if let pendingVc = pendingViewControllers.first as? LKReadSingleViewController {
            readingVc = pendingVc
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if let previousVc = previousViewControllers.first as? LKReadSingleViewController {
            if !completed {
                readingVc = previousVc
            }
        }
    }
    
}

extension LKReadViewController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        isReverseSide = !isReverseSide
        return findLastPage()
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        isReverseSide = !isReverseSide
        return findNextPage()
    }
    
}

extension LKReadViewController: LKReadMenuViewDelegate {
    
    func exitReading() {
        dismiss(animated: true, completion: nil)
    }
    
    func choosedChapter(chapterId: String) {
        readChapter(chapterId: chapterId)
    }
    
    func changeReadBackground() {
        readingVc.renewBackImg()
    }
    
    func changeReadFont() {
        dividChapterContent(chapterId: readingPosition.chapterId)
        readChapter(chapterId: readingPosition.chapterId, page: readingPosition.page)
    }
    
    func lastChapter() {
        guard let chapterModel = bookModel?.chapters?[readingPosition.chapterId],
              let lastChapterId = chapterModel.lastChapterId else {
                print("已到达开头")
                return
        }
        readChapter(chapterId: lastChapterId)
    }
    
    func nextChapter() {
        guard let chapterModel = bookModel?.chapters?[readingPosition.chapterId],
            let nextChapterId = chapterModel.nextChapterId else {
                print("已到达结尾")
                return
        }
        readChapter(chapterId: nextChapterId)
    }
    
    func pageChange(value: Float) {
        if let pageCount = bookModel?.chapters?[readingPosition.chapterId]?.pageContentArr?.count {
            readChapter(chapterId: readingPosition.chapterId, page: Int(Float(pageCount - 1) * value))
        }
    }
    
    func transitionStyleChange(style: LKTransitionStyle) {
        if transitionStyle != style {
            transitionStyle = style
            initUI()
        }
    }
    
}

extension LKReadViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if let touchView = touch.view {
            if touchView.isDescendant(of: menuView.titleTabView) {
                return false
            }
        }
        return true
    }
}
