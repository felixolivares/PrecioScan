//
//  PageRemoveAds.swift
//  PrecioScan
//
//  Created by Félix Olivares on 28/01/18.
//  Copyright © 2018 Felix Olivares. All rights reserved.
//

import UIKit
import SwiftyOnboard

class PageRemoveAds: SwiftyOnboardPage {

    class func instanceFromNib() -> UIView {
        return UINib(nibName: "PageRemoveAds", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
    }

}
