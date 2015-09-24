//
//  InfinitePagingView.swift
//  InfinitePagingView
//
//  Created by nakazy on 2015/06/24.
//  Copyright (c) 2015年 nakazy. All rights reserved.
//

import UIKit

protocol InfinitePagingViewDelegate: class {
    func pagingView(pagingView: InfinitePagingView, willBeginDragging scrollView: UIScrollView)
    func pagingView(pagingView: InfinitePagingView, didScroll scrollView: UIScrollView)
    func pagingView(pagingView: InfinitePagingView, didEndDragging scrollView: UIScrollView)
    func pagingView(pagingView: InfinitePagingView, willBeginDecelerating scrollView: UIScrollView)
    func pagingView(pagingView: InfinitePagingView, didEndDecelerating scrollView: UIScrollView, atPageIndex pageIndex: Int)
}

class InfinitePagingView: UIView, UIScrollViewDelegate {
    
    private var pageSize: CGSize!
    private var pageViews: [UIView] = []
    private var innerScrollView: UIScrollView!
    private var lastPageIndex: Int = 0
    private var currentPageIndex: Int = 0
    private var delegate: InfinitePagingViewDelegate?
    
    enum InfinitePagingViewScrollDirection {
        case InfinitePagingViewHorizonScrollDirection, InfinitePagingViewVerticalScrollDirection
    }
    
    private var scrollDirection: InfinitePagingViewScrollDirection!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.userInteractionEnabled = true
        self.clipsToBounds = true
        innerScrollView = UIScrollView(frame: frame)
        innerScrollView.delegate = self
        innerScrollView.backgroundColor = UIColor.clearColor()
        innerScrollView.clipsToBounds = false
        innerScrollView.pagingEnabled = true
        innerScrollView.scrollEnabled = true
        innerScrollView.showsHorizontalScrollIndicator = false
        innerScrollView.showsVerticalScrollIndicator = false
        innerScrollView.scrollsToTop = false
        scrollDirection = .InfinitePagingViewHorizonScrollDirection
        self.addSubview(innerScrollView)
        self.pageSize = frame.size
    }
    
    func addPageView(pageView: UIView) {
        pageViews.append(pageView)
        layoutPages()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutPages()
    }
    
    func layoutPages() {
        if scrollDirection == .InfinitePagingViewHorizonScrollDirection {
            let leftMargin = (self.frame.size.width - pageSize.width) / 2;
            innerScrollView.frame = CGRect(x: leftMargin, y: 0.0, width: pageSize.width, height: self.frame.size.height)
            innerScrollView.contentSize = CGSize(width: self.frame.size.width * CGFloat(pageViews.count), height: self.frame.size.height)
        } else {
            let topMargin  = (self.frame.size.height - pageSize.height) / 2;
            innerScrollView.frame = CGRect(x: 0.0, y: topMargin, width: self.frame.size.width, height: pageSize.height)
            innerScrollView.contentSize = CGSize(width: self.frame.size.width, height: self.frame.size.height * CGFloat(pageViews.count))
        }
        var idx = 0
        for pageView in pageViews {
            if scrollDirection == .InfinitePagingViewHorizonScrollDirection {
                pageView.center = CGPoint(x: CGFloat(idx) * (innerScrollView.frame.size.width) + (innerScrollView.frame.size.width / 2), y: innerScrollView.center.y)
            } else {
                pageView.center = CGPoint(x: innerScrollView.center.x, y: CGFloat(idx) * (innerScrollView.frame.size.height) + (innerScrollView.frame.size.height / 2))
            }
            innerScrollView.addSubview(pageView)
            idx++
        }
        lastPageIndex = Int(floor(Double(pageViews.count) / 2.0))
        if scrollDirection == .InfinitePagingViewHorizonScrollDirection {
            innerScrollView.contentSize = CGSize(width: CGFloat(pageViews.count) * innerScrollView.frame.size.width, height: self.frame.size.height)
            innerScrollView.contentOffset = CGPoint(x: pageSize.width * CGFloat(lastPageIndex), y: 0)
        } else {
            innerScrollView.contentSize = CGSize(width: innerScrollView.frame.size.width, height: pageSize.height * CGFloat(pageViews.count))
            innerScrollView.contentOffset = CGPoint(x: 0, y: pageSize.height * CGFloat(lastPageIndex))
        }
    }
    
    func scrollToDirection(moveDirection: Int,  animated: Bool) {
        var adjustScrollRect: CGRect
        if scrollDirection == .InfinitePagingViewHorizonScrollDirection {
            if fmod(innerScrollView.contentOffset.x, pageSize.width) != 0 {
                return
            }
            adjustScrollRect = CGRect(x: innerScrollView.contentOffset.x - innerScrollView.frame.size.width * CGFloat(moveDirection), y: innerScrollView.contentOffset.y, width: innerScrollView.frame.size.width, height: innerScrollView.frame.size.height)
        } else {
                if fmod(innerScrollView.contentOffset.y, pageSize.height) != 0 {
                    return
                }
                adjustScrollRect = CGRect(x: innerScrollView.contentOffset.x, y: innerScrollView.contentOffset.y - innerScrollView.frame.size.height * CGFloat(moveDirection), width: innerScrollView.frame.size.width, height: innerScrollView.frame.size.height)
        }
        innerScrollView.scrollRectToVisible(adjustScrollRect, animated:animated)
    }
    
    // UIScrollViewDelegate methods
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        delegate?.pagingView(self, willBeginDragging: innerScrollView)
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        delegate?.pagingView(self, didScroll: innerScrollView)
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView) {
        delegate?.pagingView(self, didEndDragging: innerScrollView)
    }
    
    func scrollViewWillBeginDecelerating(scrollView: UIScrollView) {
        delegate?.pagingView(self, willBeginDecelerating: innerScrollView)
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        var pageIndex = 0
        if scrollDirection == .InfinitePagingViewHorizonScrollDirection {
            pageIndex = Int(innerScrollView.contentOffset.x / innerScrollView.frame.size.width)
        } else {
            pageIndex = Int(innerScrollView.contentOffset.y / innerScrollView.frame.size.height)
        }
            
        let moveDirection = pageIndex - lastPageIndex
        if moveDirection == 0 {
            return
        } else if moveDirection > 0 {
            for var i = 0; i < abs(moveDirection); ++i {
                let leftView = pageViews[0]
                pageViews.removeAtIndex(0)
                pageViews.insert(leftView, atIndex: pageViews.count)
            }
            pageIndex -= moveDirection;
        } else if moveDirection < 0 {
            for var i = 0; i < abs(moveDirection); ++i {
                let rightView = pageViews.last
                pageViews.removeLast()
                pageViews.insert(rightView!, atIndex: 0)
            }
            pageIndex += abs(moveDirection);
        }
        
        if pageIndex > pageViews.count - 1 {
            pageIndex = pageViews.count - 1
        }
        
        var idx = 0;
        for var i = 0; i < pageViews.count; i++ {
            let pageView = pageViews[idx]
            if scrollDirection == .InfinitePagingViewHorizonScrollDirection {
                pageView.center = CGPoint(x: CGFloat(idx) * innerScrollView.frame.size.width + innerScrollView.frame.size.width / 2, y: innerScrollView.center.y)
            } else {
                pageView.center = CGPoint(x: innerScrollView.center.x, y: CGFloat(idx) * (innerScrollView.frame.size.height) + (innerScrollView.frame.size.height / 2))
            }
                ++idx
        }
        self.scrollToDirection(moveDirection, animated: false)
        
        lastPageIndex = pageIndex;
        
        currentPageIndex += moveDirection
        if currentPageIndex < 0 {
            currentPageIndex = pageViews.count - 1
        } else if currentPageIndex >= pageViews.count {
            currentPageIndex = 0
        }
        delegate?.pagingView(self, didEndDecelerating: innerScrollView, atPageIndex: currentPageIndex)
    }
}
