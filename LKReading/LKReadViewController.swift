//
//  LKReadViewController.swift
//  LKReading
//
//  Created by klike on 2018/5/28.
//  Copyright © 2018年 kLike. All rights reserved.
//

import UIKit

class LKReadViewController: UIViewController {
    
    var bookModel: LKReadModel?
    var readChapterIndex = 0
    
    lazy var pageViewController: UIPageViewController = {
        let page = UIPageViewController(transitionStyle: .pageCurl, navigationOrientation: .horizontal, options: nil)
//        page.isDoubleSided = true
        page.dataSource = self
        page.delegate = self
        addChildViewController(page)
        let contentVc = LKReadSingleViewController()
        contentVc.contentView.content = bookModel?.chapterArr?.first?.content ?? "null"
        page.setViewControllers([contentVc], direction: .forward, animated: true, completion: nil)
        return page
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(pageViewController.view)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension LKReadViewController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard readChapterIndex > 0,
            let chapterModel = bookModel?.chapterArr?[readChapterIndex], chapterModel.lastChapterId != "start",
            let lastChapterModel = bookModel?.chapterArr?[readChapterIndex - 1] else {
            return nil
        }
        let contentVc = LKReadSingleViewController()
        contentVc.contentView.content = lastChapterModel.content
        return contentVc
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let chapterCount = bookModel?.chapterArr?.count, readChapterIndex <  chapterCount - 1,
            let chapterModel = bookModel?.chapterArr?[readChapterIndex], chapterModel.lastChapterId != "end",
            let nextChapterModel = bookModel?.chapterArr?[readChapterIndex + 1] else {
                return nil
        }
        let contentVc = LKReadSingleViewController()
        contentVc.contentView.content = nextChapterModel.content
        return contentVc
    }
    
}

extension LKReadViewController: UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        readChapterIndex += 1
    }
    
}
