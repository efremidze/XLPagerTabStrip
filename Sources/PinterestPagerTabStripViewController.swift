//  PinterestPagerTabStripViewController.swift
//  XLPagerTabStrip ( https://github.com/xmartlabs/XLPagerTabStrip )
//
//  Copyright (c) 2016 Xmartlabs ( http://xmartlabs.com )
//
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import Foundation

public struct PinterestPagerTabStripSettings {
    
    public struct Style {
        public var switchBackgroundColor = UIColor(white: 0.84, alpha: 1)
        public var switchSelectedBackgroundColor = UIColor(white: 0.97, alpha: 1)
        public var switchTitleColor = UIColor(white: 0.62, alpha: 1)
        public var switchSelectedTitleColor = UIColor(white: 0.15, alpha: 1)
        public var switchTitleFont = UIFont.boldSystemFontOfSize(15)
        public var switchCornerRadius: CGFloat = 4
        public var switchSelectedBackgroundInset: CGFloat = 2
    }
    
    public var style = Style()
    
}

public class PinterestPagerTabStripViewController: PagerTabStripViewController, PagerTabStripDataSource, PagerTabStripIsProgressiveDelegate {
        
    public var settings = PinterestPagerTabStripSettings()
    public var changeCurrentIndexProgressive: ((progressPercentage: CGFloat, changeCurrentIndex: Bool, animated: Bool) -> Void)?
    
    @IBOutlet public lazy var switchView: DGRunkeeperSwitch! = DGRunkeeperSwitch()
    
    private var shouldUpdateSwitchView = true
    
    override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        delegate = self
        datasource = self
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        delegate = self
        datasource = self
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        if switchView.superview == nil {
            guard let navigationController = navigationController else {
                fatalError("PinterestPagerTabStripViewController should be embedded in a UINavigationController")
            }
            switchView.frame.size.width = navigationController.navigationBar.bounds.width - 20
            switchView.frame.size.height = navigationController.navigationBar.bounds.height - 8
            switchView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
            navigationItem.titleView = switchView
        }
        switchView.backgroundColor = settings.style.switchBackgroundColor
        switchView.selectedBackgroundColor = settings.style.switchSelectedBackgroundColor
        switchView.titleColor = settings.style.switchTitleColor
        switchView.selectedTitleColor = settings.style.switchSelectedTitleColor
        switchView.titleFont = settings.style.switchTitleFont
        switchView.cornerRadius = settings.style.switchCornerRadius
        switchView.selectedBackgroundInset = settings.style.switchSelectedBackgroundInset
        switchView.selectedIndexChanged = selectedIndexChanged
        reloadSwitchView()
    }
    
    func selectedIndexChanged(index: CGFloat, animated: Bool) {
        shouldUpdateSwitchView = false
        
        if index == floor(index) {
            moveToViewControllerAtIndex(Int(index), animated: animated)
        } else {
            (navigationController?.view ?? view).userInteractionEnabled = false
            containerView.setContentOffset(CGPointMake(index * containerView.bounds.width, 0), animated: animated)
        }
        
        (navigationController?.view ?? view).userInteractionEnabled = true
    }
    
    func reloadSwitchView() {
        switchView.titles = viewControllers.map { ($0 as! IndicatorInfoProvider).indicatorInfoForPagerTabStrip(self).title }
    }
    
    // MARK: - PagerTabStripIsProgressiveDelegate
    
    public func pagerTabStripViewController(pagerTabStripViewController: PagerTabStripViewController, updateIndicatorFromIndex fromIndex: Int, toIndex: Int) {
        fatalError()
    }
    
    public func pagerTabStripViewController(pagerTabStripViewController: PagerTabStripViewController, updateIndicatorFromIndex fromIndex: Int, toIndex: Int, withProgressPercentage progressPercentage: CGFloat, indexWasChanged: Bool) {
        if shouldUpdateSwitchView {
            var index = CGFloat(toIndex)
            if progressPercentage < 1 {
                index = CGFloat(fromIndex)
                if toIndex > fromIndex {
                    index += progressPercentage
                } else {
                    index -= progressPercentage
                }
            }
            index = max(0, min(CGFloat(viewControllers.count) - 1, index))
            switchView.setSelectedIndex(index, animated: false)
        }
        changeCurrentIndexProgressive?(progressPercentage: progressPercentage, changeCurrentIndex: indexWasChanged, animated: true)
    }
    
    // MARK: - UIScrollViewDelegate
    
    public override func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
        super.scrollViewDidEndScrollingAnimation(scrollView)
        
        guard scrollView == containerView else { return }
        shouldUpdateSwitchView = true
    }
    
}
