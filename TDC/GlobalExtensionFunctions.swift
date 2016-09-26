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
    
    class func getFittedLabelWithTitle(text: String) -> UILabel{
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 40))
        label.text = text
        label.textColor = UIColor.whiteColor()
        label.textAlignment = .Center
        label.numberOfLines = 0
        label.font = UIFont(name: "Arial", size: 20)
        label.adjustsFontSizeToFitWidth = true
        return label
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
    
    func isInDateList(dates: [Date], calendar: NSCalendar) -> Bool {
        for date in dates {
            if let d = date.date {
                if calendar.compareDate(d, toDate: self, toUnitGranularity: .Day) == .OrderedSame {
                    return true
                }
            }
        }
        return false
    }
    
    class func toMidnight(date: NSDate, calendar: NSCalendar) -> NSDate{
        let comp = calendar.components([.Day, .Month, .Year], fromDate: date)
        return calendar.dateFromComponents(comp)!
    }
}


