//
//  LineRefreshControl.swift
//  LineRefreshControlDemo
//
//  Created by zhuscat on 15/11/29.
//  Copyright © 2015 zhuscat. All rights reserved.
//

import UIKit

@objc protocol LineRefreshControlDelegate {
    func lineRefreshTableHeaderDidTriggerRefresh(view: LineRefreshControl)
    func lineRefreshTableHeaderDataSourceIsLoading(view: LineRefreshControl) -> Bool
}

class AnimatedLineView: UIView {
    let topLine = CAShapeLayer()
    let middleLine = CAShapeLayer()
    let bottomLine = CAShapeLayer()
    var triggerHeight: CGFloat!
    var isAnimating: Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.blackColor()
        let path = UIBezierPath()
        path.moveToPoint(CGPoint(x: 0, y: 0))
        path.addLineToPoint(CGPoint(x: 24, y: 0))
        let strokingPath = CGPathCreateCopyByStrokingPath(path.CGPath, nil, 4, CGLineCap.Round, CGLineJoin.Miter, 4)
        
        for line in [topLine, middleLine, bottomLine] {
            line.path = path.CGPath
            line.bounds = CGPathGetPathBoundingBox(strokingPath)
            line.strokeColor = UIColor.grayColor().CGColor
            line.fillColor = UIColor.clearColor().CGColor
            line.lineWidth = 4
            line.lineCap = kCALineCapRound
            line.lineJoin = kCALineJoinMiter
            line.miterLimit = 4.0
            line.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            line.actions = [
                "transform": NSNull(),
                "position": NSNull()
            ]
            layer.addSublayer(line)
        }
        
        middleLine.position = CGPoint(x: center.x, y: bounds.size.height - 30)
        bottomLine.position = CGPoint(x: center.x, y: middleLine.position.y + 10)
        topLine.position = CGPoint(x: center.x, y: middleLine.position.y - 10)
        
        triggerHeight = (bounds.size.height - middleLine.position.y) * 2
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func startAnimation() {
        let animation1 = CAKeyframeAnimation(keyPath: "transform.scale")
        animation1.duration = 2.4
        animation1.values = [1.0, 1.2, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0]
        animation1.repeatCount = MAXFLOAT
        animation1.calculationMode = kCAAnimationCubic
        let animation2 = CAKeyframeAnimation(keyPath: "transform.scale")
        animation2.duration = 2.4
        animation2.values = [1.0, 1.0, 1.0, 1.0, 1.2, 1.0, 1.0, 1.0, 1.0]
        animation2.repeatCount = MAXFLOAT
        animation1.calculationMode = kCAAnimationCubic
        let animation3 = CAKeyframeAnimation(keyPath: "transform.scale")
        animation3.duration = 2.4
        animation3.values = [1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.2, 1.0]
        animation3.repeatCount = MAXFLOAT
        animation1.calculationMode = kCAAnimationCubic
        topLine.addAnimation(animation1, forKey: "ScaleAnimationTop")
        middleLine.addAnimation(animation2, forKey: "ScaleAnimationMiddle")
        bottomLine.addAnimation(animation3, forKey: "ScaleAnimationBottom")
        isAnimating = true
    }
    
    func stopAnimation() {
        topLine.removeAllAnimations()
        middleLine.removeAllAnimations()
        bottomLine.removeAllAnimations()
        isAnimating = false
    }
}

class LineRefreshControl: AnimatedLineView {
    
    private var state: lineRefreshState = .Normal
    
    private var endRefreshAllowed = false
    private var endRefreshAsked = false
    
    var delegate: LineRefreshControlDelegate?
    
    enum lineRefreshState {
        case Normal
        case Pulling
        case Loading
    }
    
    func setState(aState: lineRefreshState) {
        state = aState
    }
    
    func lineFreshScrollViewDidScroll(scrollView: UIScrollView) {
        if state == .Loading || isAnimating {
            if -(scrollView.contentOffset.y) < triggerHeight {
                return
            }
            else {
                configureAnimatingView(-scrollView.contentOffset.y)
            }
        }
        else {
            if -(scrollView.contentOffset.y) < triggerHeight{
                //print("has not trigger")
                if state != .Normal {
                    topLine.transform = CATransform3DIdentity
                    middleLine.transform = CATransform3DIdentity
                    bottomLine.transform = CATransform3DIdentity
                    middleLine.position = CGPoint(x: center.x, y: bounds.size.height - 30)
                    bottomLine.position = CGPoint(x: center.x, y: middleLine.position.y + 10)
                    topLine.position = CGPoint(x: center.x, y: middleLine.position.y - 10)
                }
                
                setState(.Normal)
            }
            else if -(scrollView.contentOffset.y) < triggerHeight + 80 {
                //print("can animate")
                configureViewPositon(-scrollView.contentOffset.y)
                configureViewRotate(-scrollView.contentOffset.y)
                setState(.Pulling)
            }
            else {
                //print("must animate")
                if !isAnimating {
                    configureViewPositon(-scrollView.contentOffset.y)
                    topLine.transform = CATransform3DIdentity
                    middleLine.transform = CATransform3DIdentity
                    bottomLine.transform = CATransform3DIdentity
                    startAnimation()
                }
                else {
                    configureAnimatingView(-scrollView.contentOffset.y)
                }
                setState(.Pulling)
            }
        }
    }
    
    func lineFreshScrollViewDidEndDragging(scrollView: UIScrollView) {
        print("lineRereshScrollViewDidEndDragging")
        
        var loading = false
        
        if let load = delegate?.lineRefreshTableHeaderDataSourceIsLoading(self) {
            loading = load
        }
        
        if scrollView.contentOffset.y <= -(triggerHeight + 20) && !loading {
            delegate?.lineRefreshTableHeaderDidTriggerRefresh(self)
            setState(.Loading)
            topLine.transform = CATransform3DIdentity
            middleLine.transform = CATransform3DIdentity
            bottomLine.transform = CATransform3DIdentity
            if (!isAnimating){
                startAnimation()
            }
            
            let contentOffset = scrollView.contentOffset
            
            print("The content offset is \(contentOffset)")
            
            UIView.animateWithDuration(0.2, animations: { () -> Void in
                
                scrollView.contentInset = UIEdgeInsetsMake(60, 0, 0, 0)
                scrollView.contentOffset = contentOffset;          // Workaround for smooth transition on iOS8
                }, completion: { (completed) -> Void in
                    NSLog("completed")
                    let dispatchTime: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(0.6 * Double(NSEC_PER_SEC)))
                    dispatch_after(dispatchTime, dispatch_get_main_queue(), {
                        // your function here
                        self.endRefreshAllowed = true
                        if self.endRefreshAsked {
                            self.endRefreshAsked = false
                            self.lineRefreshScrollViewDataSourceDidFinishedLoading(scrollView)
                        }
                    })
                    
                    
            })
        }
        else {
            print("endDrag")
            if isAnimating {
                stopAnimation()
            }
        }
    }
    
    func lineRefreshScrollViewDataSourceDidFinishedLoading(scrollView: UIScrollView) {
        //print("before endRefreshAllowed: \(endRefreshAllowed)")
        //print("before endRefreshAsked: \(endRefreshAsked)")
        
        if !endRefreshAllowed {
            endRefreshAsked = true
            return
        }
        
        endRefreshAllowed = false
        
        setState(.Normal)
        UIView.animateWithDuration(0.3, delay: 0.1, options: .CurveLinear, animations: { () -> Void in
            scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
            scrollView.contentOffset = CGPointMake(0, 0)
            }, completion: { (finished) -> Void in
                self.stopAnimation()
                scrollView.userInteractionEnabled = true
        })
        
        //print("after endRefreshAllowed: \(endRefreshAllowed)")
        //print("after endRefreshAsked: \(endRefreshAsked)")
    }
    
    func configureViewPositon(contentOffset: CGFloat) {
            let y = sin(CGFloat(M_PI_4) * (contentOffset - triggerHeight) / (triggerHeight + 80)) * 14
            topLine.position = CGPoint(x: center.x, y: middleLine.position.y - 2 * y - 10)
            middleLine.position = CGPoint(x: center.x, y: frame.size.height - contentOffset / 2)
            bottomLine.position = CGPoint(x: center.x, y: middleLine.position.y + 2 * y + 10)
    }
    
    func configureAnimatingView(contentOffset: CGFloat) {
        topLine.position = CGPoint(x: center.x, y: middleLine.position.y - 10)
        middleLine.position = CGPoint(x: center.x, y: frame.size.height - contentOffset / 2)
        bottomLine.position = CGPoint(x: center.x, y: middleLine.position.y + 10)
    }
    
    func configureViewRotate(contentOffset: CGFloat) {
        topLine.transform = CATransform3DRotate(CATransform3DIdentity, CGFloat(M_PI_4) * (contentOffset - triggerHeight) / (triggerHeight + 80), 0, 0, 1)
        middleLine.transform = CATransform3DRotate(CATransform3DIdentity, CGFloat(-M_PI_4) * (contentOffset - triggerHeight) / (triggerHeight + 80), 0, 0, 1)
        bottomLine.transform = CATransform3DRotate(CATransform3DIdentity, CGFloat(M_PI_4) * (contentOffset - triggerHeight) / (triggerHeight + 80), 0, 0, 1)
    }
}