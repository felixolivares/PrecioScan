//
//  Extensions.swift
//  PrecioScan
//
//  Created by Félix Olivares on 17/10/17.
//  Copyright © 2017 Felix Olivares. All rights reserved.
//

import Foundation
import UIKit
//import TransitionButton

extension UILabel{
    func bounce(completionHandler: @escaping(Bool) -> Void){
        self.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: 0.3, initialSpringVelocity: 0.1, options: UIViewAnimationOptions.beginFromCurrentState, animations: {
            self.transform = CGAffineTransform(scaleX: 1, y: 1)
        }) { (finished) in
            if finished {
                completionHandler(true)
            }else{
                completionHandler(false)
            }
        }
    }
}

extension Float{
    func formatDecimals() -> String {
        return String(format: "%.2f", self)
    }
}

//extension TransitionButton{
//    func setLoading(){
//        self.layer.borderColor = UIColor.clear.cgColor
//        self.layer.borderWidth = 1
//        self.layer.cornerRadius = 10
//        self.disabledBackgroundColor = UIColor.white
//    }
//}

extension UIView{
    func bounce(){
        self.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        UIView.animate(withDuration: 1,
                       delay: 0,
                       usingSpringWithDamping: 0.4,
                       initialSpringVelocity: 0.2,
                       options: UIViewAnimationOptions.beginFromCurrentState,
                       animations: {
                        self.transform = CGAffineTransform(scaleX: 1, y: 1)
        })
    }
}

class RoundedCorners: UIView{
    @IBInspectable var corner: CGFloat = 0 {
        didSet {
            layer.cornerRadius = corner
            layer.masksToBounds = corner > 0
            layer.borderWidth = 1.0
            layer.borderColor = UIColor(liveGreen)?.cgColor
        }
    }
}

class RoundedButton: UIButton{
    @IBInspectable var corner: CGFloat = 0 {
        didSet{
            layer.cornerRadius = corner
            layer.borderColor = UIColor.clear.cgColor
        }
    }
}
