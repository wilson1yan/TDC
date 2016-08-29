//
//  DaysLeftView.swift
//  TDC
//
//  Created by Wilson Yan on 8/18/16.
//  Copyright © 2016 Wilson Yan. All rights reserved.
//

import UIKit

class DaysLeftView: UIView {
    
    private let durationRatio = 1/(M_PI) // pi radians/second
    private var alreadyAddedGradientView = false
    
    var days: Double? {
        didSet {
            numFont = adjustFontSizeToFitRect(rectForNum, text: String(Int(days!)))
            textFont = adjustFontSizeToFitRect(rectForDaysLeftText, text: days! == 1 ? "Day" : "Days")
            setNeedsDisplay()
        
            totalRadians = days!/duration*M_PI*2
            if oldValue != nil {
                changeInRadians = (days!-oldValue!)/duration*M_PI*2
            }
        }
    }
    
    private var changeInRadians: Double = 0.0
    private var totalRadians: Double!
    
    var duration: Double! {
        didSet {
            if oldValue != nil && days != nil{
                changeInRadians = (days!/duration - days!/oldValue)*M_PI*2
            }
        }
    }
    
    private let ROOT_2: CGFloat = sqrt(2)
    
    private var sideLength: CGFloat { return min(bounds.size.width, bounds.size.height) }
    private var circleRadius: CGFloat { return sideLength/2 * 0.8}
    private var circleRect: CGRect { return CGRect(origin: CGPoint(x: bounds.size.width/2 - circleRadius, y: bounds.size.height/2 - circleRadius), size: CGSize(width: 2*circleRadius, height: 2*circleRadius)) }
    private var circleCenter: CGPoint { return CGPoint(x: bounds.size.width/2, y: bounds.size.height/2) }
    private var largestRectInCircle: CGRect { return CGRect(x: circleCenter.x - ROOT_2/2*circleRadius, y: circleCenter.y - ROOT_2/2*circleRadius, width: circleRadius*ROOT_2, height: circleRadius*ROOT_2) }
    
    private var rectForNum: CGRect { return CGRect(origin: largestRectInCircle.origin, size: CGSize(width: largestRectInCircle.width, height: largestRectInCircle.height*0.75)) }
    private var rectForDaysLeftText: CGRect { return CGRect(origin: CGPoint(x: largestRectInCircle.origin.x, y: largestRectInCircle.origin.y + largestRectInCircle.height*0.75), size: CGSize(width: largestRectInCircle.width, height: largestRectInCircle.height*0.25)) }
    private var numFont: UIFont?
    private var textFont: UIFont?
    private var gradentView: UIView!
    
    override func layoutSubviews() {
        createGradient()
        createAnimatedCircleMask()
    }
    
    override func drawRect(rect: CGRect) {
        UIColor(red:0.95, green:0.95, blue:0.95, alpha:1.0).setStroke()
        let circle = UIBezierPath(ovalInRect: circleRect)
        circle.lineWidth = 5
        circle.stroke()
        
        if days != nil && duration != nil{
            let paraStyle = NSMutableParagraphStyle()
            paraStyle.alignment = NSTextAlignment.Center
            let f1 = numFont != nil ? numFont! : UIFont(name: "Arial", size: rectForNum.height*0.9)!
            let f2 = textFont != nil ? textFont! : UIFont(name: "Arial", size: rectForDaysLeftText.height*0.9)!
            
            let attributesForNum = [
                NSForegroundColorAttributeName: UIColor.blackColor(),
                NSFontAttributeName: f1,
                NSParagraphStyleAttributeName: paraStyle
            ]
            let attributesForText = [
                NSForegroundColorAttributeName: UIColor.blackColor(),
                NSFontAttributeName: f2,
                NSParagraphStyleAttributeName: paraStyle
            ]
            
            NSString(string: String(Int(days!))).drawInRect(rectForNum, withAttributes: attributesForNum)
            NSString(string: days! == 1 ? "Day" : "Days").drawInRect(rectForDaysLeftText, withAttributes: attributesForText)
        }
    }
    
//    func animateAddRadians() {
//        if radiansToAdd != nil {
//            let totalRadians = (days!/duration!)*M_PI*2
//            createAnimatedCircleMask(totalRadians, changeInRadians: radiansToAdd!)
//        }
//    }
    
    private let colorSpace = CGColorSpaceCreateDeviceRGB()
    private let colors: [CGFloat] = [
        0.0, 0.0, 1.0, 1.0,
        0.0, 1.0, 0.0, 1.0
    ]

    private func createGradient() {
        gradentView = UIView(frame: bounds)
        insertSubview(gradentView, atIndex: 0)
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = gradentView.bounds
        gradientLayer.colors = [UIColor.blueColor().CGColor, UIColor.greenColor().CGColor]
        gradentView.layer.addSublayer(gradientLayer)
    }
    
    func createAnimatedCircleMask() {
        let alayer = CAShapeLayer()
        alayer.fillColor = nil
        alayer.lineWidth = 5.0
        alayer.strokeStart = 0.0
        alayer.strokeEnd = CGFloat(changeInRadians >= 0 ? 1.0 : (totalRadians+changeInRadians)/totalRadians)
        alayer.strokeColor = UIColor.blueColor().CGColor
        alayer.path = UIBezierPath(arcCenter: circleCenter, radius: circleRadius, startAngle: CGFloat(-M_PI_2), endAngle: CGFloat(-M_PI_2+totalRadians), clockwise: true).CGPath
        let animateStrokeEnd = CABasicAnimation(keyPath: "strokeEnd")
        if changeInRadians >= 0 {
            animateStrokeEnd.fromValue = CGFloat(1-changeInRadians/totalRadians)
            animateStrokeEnd.toValue = 1.0
        } else {
            animateStrokeEnd.fromValue = 1.0
            animateStrokeEnd.toValue = CGFloat((totalRadians+changeInRadians)/totalRadians)
        }
        animateStrokeEnd.duration = abs(changeInRadians)*durationRatio

        alayer.addAnimation(animateStrokeEnd, forKey: "strokeEndAnimation")
        gradentView.layer.mask = alayer

    }
    
    private func adjustFontSizeToFitRect(rect: CGRect, text: String) -> UIFont?{
        var font = UIFont(name: "Arial", size: 100)!
        let maxFontSize: CGFloat = 100.0
        let minFontSize: CGFloat = 5.0
        
        var q = Int(maxFontSize)
        var p = Int(minFontSize)
        
        let constraintSize = CGSize(width: rect.width, height: CGFloat.max)
        
        while(p <= q){
            let currentSize = (p + q) / 2
            font = font.fontWithSize( CGFloat(currentSize) )
            let text = NSAttributedString(string: text, attributes: [NSFontAttributeName:font])
            let textRect = text.boundingRectWithSize(constraintSize, options: .UsesLineFragmentOrigin, context: nil)
            
            let labelSize = textRect.size
            
            if labelSize.height < rect.height &&
                labelSize.height >= rect.height-10 &&
                labelSize.width < rect.width &&
                labelSize.width >= rect.width-10 {
                break
            }else if labelSize.height > rect.height || labelSize.width > rect.width{
                q = currentSize - 1
            }else{
                p = currentSize + 1
            }
        }
        
        return UIFont(name: "Arial", size: CGFloat((p+q)/2))
    }
}

