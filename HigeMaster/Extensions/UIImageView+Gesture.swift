//
//  UIImageView+Gesture.swift
//  HigeMaster
//
//  Created by 藤井陽介 on 2016/10/04.
//  Copyright © 2016年 touyou. All rights reserved.
//

import UIKit

class GestureUIImageView: UIImageView {
    //* Gesture Enabled Whether or not */
    var gestureEnabled = true
    
    // private variables
    fileprivate var beforePoint = CGPoint(x: 0.0, y: 0.0)
    fileprivate var currentScale:CGFloat = 1.0
    
    required override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.isUserInteractionEnabled = true
        
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(GestureUIImageView.handleGesture(_:)))
        self.addGestureRecognizer(pinchGesture)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(GestureUIImageView.handleGesture(_:)))
        self.addGestureRecognizer(tapGesture)
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(GestureUIImageView.handleGesture(_:)))
        self.addGestureRecognizer(longPressGesture)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(GestureUIImageView.handleGesture(_:)))
        self.addGestureRecognizer(panGesture)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @objc func handleGesture(_ gesture: UIGestureRecognizer){
        if let tapGesture = gesture as? UITapGestureRecognizer{
            tap(tapGesture)
        }else if let pinchGesture = gesture as? UIPinchGestureRecognizer{
            pinch(pinchGesture)
        }else if let panGesture = gesture as? UIPanGestureRecognizer{
            pan(panGesture)
        }
    }
    
    fileprivate func pan(_ gesture:UIPanGestureRecognizer){
        if self.gestureEnabled{
            
            if let gestureView = gesture.view{
                
                var translation = gesture.translation(in: gestureView)
                
                if abs(self.beforePoint.x) > 0.0 || abs(self.beforePoint.y) > 0.0{
                    translation = CGPoint(x: self.beforePoint.x + translation.x, y: self.beforePoint.y + translation.y)
                }
                
                switch gesture.state{
                case .changed:
                    let scaleTransform = CGAffineTransform(scaleX: self.currentScale, y: self.currentScale)
                    let translationTransform = CGAffineTransform(translationX: translation.x, y: translation.y)
                    self.transform = scaleTransform.concatenating(translationTransform)
                case .ended , .cancelled:
                    self.beforePoint = translation
                default:
                    NSLog("no action")
                }
            }
        }
    }
    
    fileprivate func tap(_ gesture:UITapGestureRecognizer){
        if self.gestureEnabled{
            UIView.animate(withDuration: 0.2, animations: { () -> Void in
                self.beforePoint = CGPoint(x: 0.0, y: 0.0)
                self.currentScale = 1.0
                self.transform = CGAffineTransform.identity
            })
        }
    }
    
    fileprivate func pinch(_ gesture:UIPinchGestureRecognizer){
        
        if self.gestureEnabled{
            
            var scale = gesture.scale
            if self.currentScale > 1.0{
                scale = self.currentScale + (scale - 1.0)
            }
            switch gesture.state{
            case .changed:
                let scaleTransform = CGAffineTransform(scaleX: scale, y: scale)
                let transitionTransform = CGAffineTransform(translationX: self.beforePoint.x, y: self.beforePoint.y)
                self.transform = scaleTransform.concatenating(transitionTransform)
            case .ended , .cancelled:
                if scale <= 1.0{
                    self.currentScale = 1.0
                    self.transform = CGAffineTransform.identity
                }else{
                    self.currentScale = scale
                }
            default:
                NSLog("not action")
            }
        }
    }
}
