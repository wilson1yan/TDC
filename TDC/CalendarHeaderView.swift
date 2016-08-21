//
//  CalendarHeaderView.swift
//  TDC
//
//  Created by Wilson Yan on 8/17/16.
//  Copyright © 2016 Wilson Yan. All rights reserved.
//

import UIKit

class CalendarHeaderView: UIView {
    
    // Public variables
    var taskName = "" {
        didSet {
            taskNameFont = adjustFontSizeToFitRect(outlineRect, text: taskName)
            setNeedsDisplay()
        }
    }
    
    // Private variables
    private let scale: CGFloat = 1
    private let rectColor = UIColor(red:0.60, green:0.80, blue:1.00, alpha:1.0)
    private let roundedRectRadius: CGFloat = 5
    
    private let padding: CGFloat = 5
    private let borderWidth: CGFloat = 2
    private var width: CGFloat { return bounds.size.width - 2*padding }
    private var height: CGFloat { return bounds.size.height - 2*padding }
    
    private var outlineRect: CGRect { return CGRect(origin: CGPoint(x: padding, y: padding), size: CGSize(width: width, height: height)) }
    private var outlineOuterRect: CGRect { return CGRect(origin: CGPoint(x: padding-borderWidth, y: padding-borderWidth), size: CGSize(width: bounds.size.width-2*(padding-borderWidth), height: bounds.size.height-2*(padding-borderWidth))) }
    private var outlineBezier: UIBezierPath { return UIBezierPath(roundedRect: outlineRect, cornerRadius: roundedRectRadius)  }
    private var outlineOuterBezier: UIBezierPath { return UIBezierPath(roundedRect: outlineOuterRect, cornerRadius: roundedRectRadius) }
    
    private var taskNameFont: UIFont?
    
    override func drawRect(rect: CGRect) {
        UIColor.blueColor().setFill()
        outlineOuterBezier.fill()
        rectColor.setFill()
        outlineBezier.fill()
        
        let textColor = UIColor.whiteColor()
        let paraStyle = NSMutableParagraphStyle()
        paraStyle.alignment = NSTextAlignment.Center
        let font = taskNameFont != nil ? taskNameFont! : UIFont(name: "Arial", size: outlineRect.height*0.9)!
        let attributes = [
            NSForegroundColorAttributeName: textColor,
            NSFontAttributeName: font,
            NSParagraphStyleAttributeName: paraStyle
        ]
        let yOffset = (outlineRect.size.height - font.pointSize) / 2.0
        NSString(string: taskName).drawInRect(CGRect(x: outlineRect.origin.x, y: outlineRect.origin.y+yOffset, width: outlineRect.width, height: outlineRect.height), withAttributes: attributes)
    }
    
    func adjustFontSizeToFitRect(rect: CGRect, text: String) -> UIFont?{
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
