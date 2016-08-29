//
//  GlobalExtensionFunctions.swift
//  TDC
//
//  Created by Wilson Yan on 8/22/16.
//  Copyright © 2016 Wilson Yan. All rights reserved.
//

import UIKit

extension UILabel {
    class func adjustFontSizeToFitRect(label: UILabel, text: String) -> UIFont?{
        label.adjustsFontSizeToFitWidth = false
        label.numberOfLines = 0
        
        let labelRect = CGRect(x: label.bounds.origin.x, y: label.bounds.origin.y, width: label.bounds.width, height: label.bounds.height)
        var fontSize: CGFloat = 25
        while fontSize > 5 {
            let size = text.sizeWithAttributes([NSFontAttributeName: UIFont(name: "Arial", size: fontSize)!])
            if size.height < labelRect.height && size.width < labelRect.width {
                break
            }
            fontSize -= 1.0
        }
        
        return UIFont(name: "Arial", size: fontSize)
    }

}

extension NSDate {
    func getDaysBefore(n: Int, calendar: NSCalendar) -> NSDate {
        let comp = NSDateComponents()
        comp.day = -1
        var day = self
        for _ in 0..<n {
            day = calendar.dateByAddingComponents(comp, toDate: day, options: [])!
        }
        return day
    }
}
