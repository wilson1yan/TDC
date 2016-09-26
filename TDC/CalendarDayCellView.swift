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
    
    var normalDayColor = UIColor.black
    var weekendDayColor = UIColor.gray
    
    func setupCellBeforeDisplay(_ cellState: CellState, date: Foundation.Date, cal: Calendar, dates: [Date]?, task: Task?, isHistory: Bool) {
        dayLabel.text = cellState.text
        configureTextColor(cellState)
        animationView.backgroundColor = UIColor.white
        self.backgroundColor = UIColor.white
        animationView.state = .open
        if cellState.dateBelongsTo == .thisMonth {
            if date.isInDateList(dates!, calendar: cal) {
                animationView.state = .marked
            } else if (cal as NSCalendar).compare(date, to: Foundation.Date(), toUnitGranularity: .day) == .orderedSame && !isHistory{
                animationView.state = .today
            } else if let start = task?.startDate{
                let withStartDate = (cal as NSCalendar).compare(start, to: date, toUnitGranularity: .day)
                let withCurrentDate = (cal as NSCalendar).compare(Foundation.Date(), to: date, toUnitGranularity: .day)
                if (withStartDate == .orderedSame || withStartDate == .orderedAscending) && withCurrentDate == .orderedDescending{
                    animationView.state = .skipped
                }
            }
        }
    }
    
    func configureTextColor(_ cellState: CellState) {
        if cellState.dateBelongsTo == .thisMonth {
            dayLabel.textColor = normalDayColor
        } else {
            dayLabel.textColor = weekendDayColor
        }
    }

    func selectedDate() {
        animationView.animateSelected()
    }
}

