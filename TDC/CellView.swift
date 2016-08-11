//
//  CellView.swift
//  TDC-iOS
//
//  Created by Wilson Yan on 8/2/16.
//  Copyright © 2016 Wilson Yan. All rights reserved.
//

import JTAppleCalendar

class CellView: JTAppleDayCellView {
    
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var animationView: AnimationView!
    
    var normalDayColor = UIColor.blackColor()
    var weekendDayColor = UIColor.grayColor()
    
    func setupCellBeforeDisplay(cellState: CellState, date: NSDate, cal: NSCalendar, dates: [Date]?, task: Task?) {
        dayLabel.text = cellState.text
        configureTextColor(cellState)
        animationView.hidden = false
        animationView.backgroundColor = UIColor.whiteColor()
        self.backgroundColor = UIColor.whiteColor()
        if cellState.dateBelongsTo == .ThisMonth {
            if date.isInDateList(dates!, calendar: cal) {
                animationView.backgroundColor = UIColor.blueColor()
                self.backgroundColor = UIColor.blueColor()
            } else if cal.compareDate(date, toDate: NSDate(), toUnitGranularity: .Day) == .OrderedSame {
                animationView.backgroundColor = UIColor.redColor()
                self.backgroundColor = UIColor.whiteColor()
            } else if let start = task?.startDate{
                let withStartDate = cal.compareDate(start, toDate: date, toUnitGranularity: .Day)
                let withCurrentDate = cal.compareDate(NSDate(), toDate: date, toUnitGranularity: .Day)
                if (withStartDate == .OrderedSame || withStartDate == .OrderedAscending) && withCurrentDate == .OrderedDescending{
                    animationView.backgroundColor = UIColor.grayColor()
                    self.backgroundColor = UIColor.grayColor()
                }
            }
        }
    }
    
    func configureTextColor(cellState: CellState) {
        if cellState.dateBelongsTo == .ThisMonth {
            dayLabel.textColor = normalDayColor
        } else {
            dayLabel.textColor = weekendDayColor
        }
    }
    
    func selectedDate() {
        animationView.backgroundColor = UIColor.blueColor()
        animationView.animateWithBounceEffect {
            dispatch_async(dispatch_get_main_queue()) { [weak self] in
                self?.animationView.backgroundColor = UIColor.blueColor()
            }
        }
    }
}

class AnimationView: UIView {
    
    func animateWithFlipEffect(withCompletionHandler completionHandler:(()->Void)?) {
        AnimationClass.flipAnimation(self, completion: completionHandler)
    }
    func animateWithBounceEffect(withCompletionHandler completionHandler:(()->Void)?) {
        let viewAnimation = AnimationClass.BounceEffect()
        viewAnimation(self){ _ in
            completionHandler?()
        }
    }
    func animateWithFadeEffect(withCompletionHandler completionHandler:(()->Void)?) {
        let viewAnimation = AnimationClass.FadeOutEffect()
        viewAnimation(self) { _ in
            completionHandler?()
        }
    }
}

