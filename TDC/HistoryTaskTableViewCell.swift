//
//  HistoryTaskTableViewCell.swift
//  TDC
//
//  Created by Wilson Yan on 8/18/16.
//  Copyright © 2016 Wilson Yan. All rights reserved.
//

import UIKit

class HistoryTaskTableViewCell: UITableViewCell {

    @IBOutlet weak var taskLabel: UILabel!

    private struct CellBackgroundColor {
        static let Complete = UIColor(red:0.60, green:1.00, blue:0.60, alpha:1.0)
        static let Fail = UIColor(red:1.00, green:0.80, blue:0.80, alpha:1.0)
    }
    
    var isComplete = false {
        didSet {
            backgroundColor = isComplete ? CellBackgroundColor.Complete : CellBackgroundColor.Fail
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
