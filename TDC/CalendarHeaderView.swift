//
//  CalendarHeaderView.swift
//  TDC
//
//  Created by Wilson Yan on 8/17/16.
//  Copyright © 2016 Wilson Yan. All rights reserved.
//

import UIKit

class CalendarHeaderView: UIView {
    
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
//        UIColor.blueColor().setFill()
//        outlineOuterBezier.fill()
//        rectColor.setFill()
//        outlineBezier.fill()

    }
    
    

}
