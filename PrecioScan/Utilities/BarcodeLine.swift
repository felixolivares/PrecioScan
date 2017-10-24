//
//  BarcodeLine.swift
//  PrecioScan
//
//  Created by Félix Olivares on 12/10/17.
//  Copyright © 2017 Felix Olivares. All rights reserved.
//

import UIKit

class BarcodeLine: UIImageView {

    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    let topValue: CGFloat = 8
    let bottomValue: CGFloat = 88.0
    
    func startAnimation(){
        self.topConstraint.constant = bottomValue
        self.layoutIfNeeded()
        UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseInOut, .autoreverse, .repeat], animations: { [weak self] in
            self?.backgroundColor = UIColor(lightNicePurple)
            self?.superview?.layoutIfNeeded() ?? ()
        })
    }
    
    func endAnimation(){
        
    }
}
