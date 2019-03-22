//
//  PageOne.swift
//  PrecioScan
//
//  Created by Félix Olivares on 18/01/18.
//  Copyright © 2018 Felix Olivares. All rights reserved.
//

import UIKit
import SwiftyOnboard

class PageOne: SwiftyOnboardPage {

    class func instanceFromNib() -> UIView {
        return UINib(nibName: "PageOne", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
    }

}
