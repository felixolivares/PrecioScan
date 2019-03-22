//
//  CustomOverlay.swift
//  PrecioScan
//
//  Created by Félix Olivares on 18/01/18.
//  Copyright © 2018 Felix Olivares. All rights reserved.
//

import UIKit
import SwiftyOnboard
import PMSuperButton

class CustomOverlay: SwiftyOnboardOverlay {
    
    @IBOutlet weak var buttonContinue: UIButton!
    @IBOutlet weak var controlPage: UIPageControl!
    @IBOutlet weak var buyButton: PMSuperButton!
    
    
    class func instanceFromNib() -> UIView {
        return UINib(nibName: "CustomOverlay", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
    }

}
