//
//  CheckMarkView.swift
//  TDC
//
//  Created by Wilson Yan on 8/13/16.
//  Copyright © 2016 Wilson Yan. All rights reserved.
//

import UIKit

class CheckMarkView: UIView {
    var checked = false {
        didSet {
            setNeedsDisplay()
        }
    }
    let scale: CGFloat = 0.50
    
    private var sideLength: CGFloat {
        return min(bounds.size.width, bounds.size.height) * scale
    }
    private var origin: CGPoint{
        return CGPoint(x: bounds.size.width/2 - sideLength/2, y: bounds.size.height/2 - sideLength/2)
    }
    
    override func drawRect(rect: CGRect) {
        if checked {
            drawCheck()
        } else {
            drawHiddenCheck()
        }
    }
    
    private func drawHiddenCheck() {
        UIColor.lightGrayColor().setStroke()
        let border = UIBezierPath(rect: CGRect(origin: origin, size: CGSize(width: sideLength, height: sideLength)))
        border.lineWidth = 1.0
        border.stroke()
    }
    
    private func drawCheck() {
        UIColor.blackColor().setStroke()
        let border = UIBezierPath(rect: CGRect(origin: origin, size: CGSize(width: sideLength, height: sideLength)))
        border.lineWidth = 1.0
        border.stroke()
        
        let check = UIBezierPath()
        check.moveToPoint(CGPoint(x: 0.1*sideLength+origin.x, y: 0.5*sideLength+origin.y))
        check.addLineToPoint(CGPoint(x: 0.4*sideLength+origin.x, y: 0.7*sideLength+origin.y))
        check.addLineToPoint(CGPoint(x: 1.2*sideLength+origin.x, y: -0.2*sideLength+origin.y))
        check.lineWidth = 5
        
        UIColor.greenColor().setStroke()
        check.stroke()

    }

}
