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
    
    fileprivate var sideLength: CGFloat {
        return min(bounds.size.width, bounds.size.height) * scale
    }
    fileprivate var origin: CGPoint{
        return CGPoint(x: bounds.size.width/2 - sideLength/2, y: bounds.size.height/2 - sideLength/2)
    }
    
    override func draw(_ rect: CGRect) {
        if checked {
            drawCheck()
        } else {
            drawHiddenCheck()
        }
    }
    
    fileprivate func drawHiddenCheck() {
        UIColor.lightGray.setStroke()
        let border = UIBezierPath(rect: CGRect(origin: origin, size: CGSize(width: sideLength, height: sideLength)))
        border.lineWidth = 1.0
        border.stroke()
    }
    
    fileprivate func drawCheck() {
        UIColor.black.setStroke()
        let border = UIBezierPath(rect: CGRect(origin: origin, size: CGSize(width: sideLength, height: sideLength)))
        border.lineWidth = 1.0
        border.stroke()
        
        let check = UIBezierPath()
        check.move(to: CGPoint(x: 0.1*sideLength+origin.x, y: 0.5*sideLength+origin.y))
        check.addLine(to: CGPoint(x: 0.4*sideLength+origin.x, y: 0.7*sideLength+origin.y))
        check.addLine(to: CGPoint(x: 1.2*sideLength+origin.x, y: -0.2*sideLength+origin.y))
        check.lineWidth = 5
        
        UIColor.green.setStroke()
        check.stroke()

    }

}
