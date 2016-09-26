//
//  TaskInfoViewController.swift
//  TDC
//
//  Created by Wilson Yan on 8/21/16.
//  Copyright © 2016 Wilson Yan. All rights reserved.
//

import UIKit

class TaskInfoViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGesture = UITapGestureRecognizer(target: view, action: #selector(onTapView))
        view.addGestureRecognizer(tapGesture)
    }
    
    func onTapView(_ recognizer: UIGestureRecognizer) {
        dismiss(animated: true, completion: nil)
    }

}
