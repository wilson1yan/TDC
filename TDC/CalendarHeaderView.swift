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
    
    // Public variables
    var taskName = ""
    var daysLeft = 0 { didSet { setNeedsDisplay() } }
    
    // Private variables
    private let scale: CGFloat = 1
    private let rectColor = UIColor(red:0.60, green:0.80, blue:1.00, alpha:1.0)
    private let roundedRectRadius: CGFloat = 5
    
    private var width: CGFloat { return bounds.size.width - 20 }
    private var height: CGFloat { return bounds.size.height - 20 }
    private var origin: CGPoint { return CGPoint(x: 10, y: 10) }
    
    private var outlineRect: CGRect { return CGRect(origin: CGPoint(x: 10, y: 10), size: CGSize(width: width, height: height)) }
    private var outlineBezier: UIBezierPath {
        let path = UIBezierPath(roundedRect: outlineRect, cornerRadius: roundedRectRadius)
        path.lineWidth = 5
        return path
    }
    
    private var printedText: NSString {
        return NSString(string: taskName + ": " + String(daysLeft) + " Days Left")
    }
    
    override func drawRect(rect: CGRect) {
        rectColor.setStroke()
        rectColor.setFill()
        outlineBezier.stroke()
        outlineBezier.fill()
        
        let textColor = UIColor.blackColor()
        let textFont = UIFont(name: "Arial", size: 20)
        let paraStyle = NSMutableParagraphStyle()
        paraStyle.lineSpacing = 6.0
        paraStyle.alignment = NSTextAlignment.Center
        
        let attributes = [
            NSForegroundColorAttributeName: textColor,
            NSFontAttributeName: textFont!,
            NSParagraphStyleAttributeName: paraStyle
        ]
        printedText.drawInRect(outlineRect, withAttributes: attributes)
    }
 

}
