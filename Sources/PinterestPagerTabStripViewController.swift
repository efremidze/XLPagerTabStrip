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
        public var titleColor = UIColor.whiteColor()
    }
    
    public var style = Style()
    
}

public class PinterestPagerTabStripViewController: PagerTabStripViewController, PagerTabStripDataSource, PagerTabStripIsProgressiveDelegate {
        
    public var settings = PinterestPagerTabStripSettings()
    public var changeCurrentIndexProgressive: ((progressPercentage: CGFloat, changeCurrentIndex: Bool, animated: Bool) -> Void)?
    
    private lazy var switchView: DGRunkeeperSwitch! = { [unowned self] in
        let switchView = DGRunkeeperSwitch()
        switchView.backgroundColor = UIColor(white: 0.84, alpha: 1)
        switchView.selectedBackgroundColor = UIColor(white: 0.97, alpha: 1)
        switchView.titleColor = UIColor(white: 0.62, alpha: 1)
        switchView.selectedTitleColor = UIColor(white: 0.15, alpha: 1)
        switchView.titleFont = .boldSystemFontOfSize(15)
        switchView.cornerRadius = 4
        switchView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        return switchView
    }()
    
    private var shouldUpdateSwitchView = true
    
    private var lastIndex = 0
    
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
            navigationItem.titleView = switchView
        }
        guard let navigationController = navigationController  else {
            fatalError("PinterestPagerTabStripViewController should be embedded in a UINavigationController")
        }
        switchView.frame.size.width = navigationController.navigationBar.bounds.width - 20
        switchView.frame.size.height = navigationController.navigationBar.bounds.height - 8
        switchView.selectedIndexChanged = selectedIndexChanged
        reloadSwitchView()
    }
    
    func selectedIndexChanged(index: CGFloat, animated: Bool) {
        shouldUpdateSwitchView = false
        if animated {
            UIView.animateWithDuration(switchView.animationDuration, delay: 0, options: [.CurveEaseOut], animations: {
                self.containerView.contentOffset.x = index * self.containerView.bounds.width
            }, completion: { _ in
                self.shouldUpdateSwitchView = true
            })
        } else {
            self.containerView.contentOffset.x = index * self.containerView.bounds.width
        }
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
    
}
