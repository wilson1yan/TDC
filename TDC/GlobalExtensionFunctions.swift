//
//  GlobalExtensionFunctions.swift
//  TDC
//
//  Created by Wilson Yan on 8/22/16.
//  Copyright © 2016 Wilson Yan. All rights reserved.
//

import UIKit

extension UILabel {
    class func adjustFontSizeToFitRect(_ label: UILabel, text: String) -> UIFont?{
        label.adjustsFontSizeToFitWidth = false
        label.numberOfLines = 0
        
        let labelRect = CGRect(x: label.bounds.origin.x, y: label.bounds.origin.y, width: label.bounds.width, height: label.bounds.height)
        var fontSize: CGFloat = 25
        while fontSize > 5 {
            let size = text.size(attributes: [NSFontAttributeName: UIFont(name: "Arial", size: fontSize)!])
            if size.height < labelRect.height && size.width < labelRect.width {
                break
            }
            fontSize -= 1.0
        }
        
        return UIFont(name: "Arial", size: fontSize)
    }
    
    class func getFittedLabelWithTitle(_ text: String) -> UILabel{
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 40))
        label.text = text
        label.textColor = UIColor.white
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = UIFont(name: "Arial", size: 20)
        label.adjustsFontSizeToFitWidth = true
        return label
    }
    
}

extension Foundation.Date {
    func getDaysBefore(_ n: Int, calendar: Calendar) -> Foundation.Date {
        var comp = DateComponents()
        comp.day = -1
        var day = self
        for _ in 0..<n {
            day = (calendar as NSCalendar).date(byAdding: comp, to: day, options: [])!
        }
        return day
    }
    
    func isInDateList(_ dates: [Date], calendar: Calendar) -> Bool {
        for date in dates {
            if let d = date.date {
                if (calendar as NSCalendar).compare(d as Date, to: self, toUnitGranularity: .day) == .orderedSame {
                    return true
                }
            }
        }
        return false
    }
    
    static func toMidnight(_ date: Foundation.Date, calendar: Calendar) -> Foundation.Date{
        let comp = (calendar as NSCalendar).components([.day, .month, .year], from: date)
        return calendar.date(from: comp)!
    }
}


