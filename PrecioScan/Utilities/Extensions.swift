//
//  Extensions.swift
//  PrecioScan
//
//  Created by Félix Olivares on 17/10/17.
//  Copyright © 2017 Felix Olivares. All rights reserved.
//

import Foundation
import UIKit

extension UILabel{
    func bounce(){
        self.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        UIView.animate(withDuration: 0.8,
                       delay: 0,
                       usingSpringWithDamping: 0.3,
                       initialSpringVelocity: 0.1,
                       options: UIViewAnimationOptions.beginFromCurrentState,
                       animations: {
                        self.transform = CGAffineTransform(scaleX: 1, y: 1)
        })
    }
}
