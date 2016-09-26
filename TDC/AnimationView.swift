//
//  AnimationView.swift
//  TDC
//
//  Created by Wilson Yan on 8/14/16.
//  Copyright © 2016 Wilson Yan. All rights reserved.
//

import UIKit

class AnimationView: UIView {
    var state = CellType.open {
        didSet {
            setNeedsDisplay()
        }
    }
    enum CellType {
        case open
        case marked
        case skipped
        case today
    }
    
    var outlineRect: UIBezierPath {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: bounds.size.width, y: 0))
        path.addLine(to: CGPoint(x: bounds.size.width, y: bounds.size.height))
        path.addLine(to: CGPoint(x: 0, y: bounds.size.height))
        path.close()
        
        path.lineWidth = 1
        
        return path
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
//        UIColor.lightGrayColor().setStroke()
//        UIColor.clearColor().setFill()
//        outlineRect.stroke()
        
        switch state {
        case .marked: drawCheckMark()
        case .skipped: drawX()
        case .today: drawNeedToUpdateIcon()
        case .open: break
        }
    }
    
    var blankPath: UIBezierPath {
        let path = UIBezierPath(rect: bounds)
        path.lineWidth = 5
        return path
    }
    
    var checkMarkPath: UIBezierPath {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: bounds.size.width*0.1, y: bounds.size.height*0.5))
        path.addLine(to: CGPoint(x: bounds.size.width*0.4, y: bounds.size.height*0.8))
        path.addLine(to: CGPoint(x: bounds.size.width*0.9, y: bounds.size.height*0.1))
        
        path.lineWidth = 5
        return path
    }
    
    var xPath: UIBezierPath {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: bounds.size.width*0.1, y: bounds.size.height*0.1))
        path.addLine(to: CGPoint(x: bounds.size.width*0.9, y: bounds.size.height*0.9))
        
        path.move(to: CGPoint(x: bounds.size.width*0.1, y: bounds.size.height*0.9))
        path.addLine(to: CGPoint(x: bounds.size.width*0.9, y: bounds.size.height*0.1))
        
        path.lineWidth = 5
        return path
    }

    var updatePath: UIBezierPath {
        let path = UIBezierPath(arcCenter: CGPoint(x: bounds.size.width/2, y: bounds.size.height/2), radius: min(bounds.size.width,bounds.size.height)/2*0.8, startAngle: 0, endAngle: CGFloat(2*M_PI), clockwise: true)
        path.lineWidth = 5
        return path
    }
    
    func animateSelected() {
        state = .open
        animateBezierPath(checkMarkPath, withColor: UIColor.green.cgColor, withDuration: 0.3)
        animateBounceEffect()
    }
    
    fileprivate func animateBounceEffect() {
        let bounceAnimation = AnimationClass.BounceEffect()
        bounceAnimation(self) { [unowned self] (completed) in
            self.state = .marked
        }
    }
    
    fileprivate func animateBezierPath(_ bezierPath: UIBezierPath, withColor color: CGColor, withDuration duration: CFTimeInterval) {
        let bezierLayer = CAShapeLayer()
        bezierLayer.backgroundColor = UIColor.white.cgColor
        bezierLayer.fillColor = nil
        
        bezierLayer.path = bezierPath.cgPath
        bezierLayer.lineWidth = 5.0
        bezierLayer.strokeColor = color
        bezierLayer.strokeStart = 0.0
        bezierLayer.strokeEnd = 1.0
        
        self.layer.addSublayer(bezierLayer)
        let animateStrokeEnd = CABasicAnimation(keyPath: "strokeEnd")
        animateStrokeEnd.duration = duration
        animateStrokeEnd.fromValue = NSNumber(value: 0.0 as Float)
        animateStrokeEnd.toValue = NSNumber(value: 1.0 as Float)
        bezierLayer.add(animateStrokeEnd, forKey: "strokeEndAnimation")
    }
    
    func drawCheckMark() {
        UIColor.green.setStroke()
        checkMarkPath.stroke()
    }
    
    func drawX() {
        UIColor.red.setStroke()
        xPath.stroke()
    }
    
    func drawNeedToUpdateIcon() {
        UIColor.blue.setStroke()
        updatePath.stroke()
    }
    
    func drawBlank() {
        UIColor.white.setFill()
        blankPath.fill()
    }

}
