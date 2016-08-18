//
//  CalendarHeaderView.swift
//  TDC
//
//  Created by Wilson Yan on 8/17/16.
//  Copyright © 2016 Wilson Yan. All rights reserved.
//

import UIKit

@IBDesignable
class CalendarHeaderView: UIView {
    let scale: CGFloat = 1
    let rectColor = UIColor(red:0.60, green:0.80, blue:1.00, alpha:1.0)
    let roundedRectRadius: CGFloat = 0
    
    var width: CGFloat { return bounds.size.width * scale }
    var height: CGFloat { return bounds.size.height * scale }
    var origin: CGPoint { return CGPoint(x: bounds.size.width/2-width/2, y: bounds.size.height/2-height/2) }
    var outlineRect: CGRect { return CGRect(origin: origin, size: CGSize(width: width, height: height)) }
    var outlineBezier: UIBezierPath {
        let path = UIBezierPath(roundedRect: outlineRect, cornerRadius: roundedRectRadius)
        path.lineWidth = 5
        return path
    }
    
    var textRect: CGRect {
        return CGRect(x: bounds.size.width*0.3, y: bounds.size.height*0.25, width: bounds.size.width*0.4, height: bounds.size.height*0.5)
    }
    
    var daysLeft: NSString = "30 Days Left"
    
    override func drawRect(rect: CGRect) {
//        rectColor.setStroke()
//        rectColor.setFill()
//        outlineBezier.stroke()
//        outlineBezier.fill()
        
        let textColor = UIColor.blackColor()
        let textFont = UIFont(name: "ChalkboardSE-Regular", size: 20)
        let paraStyle = NSMutableParagraphStyle()
        paraStyle.lineSpacing = 6.0
        paraStyle.alignment = NSTextAlignment.Center
        
        let attributes = [
            NSForegroundColorAttributeName: textColor,
            NSFontAttributeName: textFont!,
            NSParagraphStyleAttributeName: paraStyle
        ]
        daysLeft.drawInRect(textRect, withAttributes: attributes)
    }
 

}
