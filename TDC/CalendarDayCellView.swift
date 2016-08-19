//
//  CellView.swift
//  TDC-iOS
//
//  Created by Wilson Yan on 8/2/16.
//  Copyright © 2016 Wilson Yan. All rights reserved.
//

import JTAppleCalendar

class CalendarDayCellView: JTAppleDayCellView {
    
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var animationView: AnimationView!
    
    var normalDayColor = UIColor.blackColor()
    var weekendDayColor = UIColor.grayColor()
    
    func setupCellBeforeDisplay(cellState: CellState, date: NSDate, cal: NSCalendar, dates: [Date]?, task: Task?) {
        dayLabel.text = cellState.text
        configureTextColor(cellState)
        animationView.backgroundColor = UIColor.whiteColor()
        self.backgroundColor = UIColor.whiteColor()
        if cellState.dateBelongsTo == .ThisMonth {
            if date.isInDateList(dates!, calendar: cal) {
                animationView.state = .Marked
            } else if cal.compareDate(date, toDate: NSDate(), toUnitGranularity: .Day) == .OrderedSame {
                animationView.state = .Today
            } else if let start = task?.startDate{
                let withStartDate = cal.compareDate(start, toDate: date, toUnitGranularity: .Day)
                let withCurrentDate = cal.compareDate(NSDate(), toDate: date, toUnitGranularity: .Day)
                if (withStartDate == .OrderedSame || withStartDate == .OrderedAscending) && withCurrentDate == .OrderedDescending{
                    animationView.state = .Skipped
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
        animationView.animateSelected()
    }
}

