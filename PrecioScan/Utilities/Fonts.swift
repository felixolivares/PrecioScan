//
//  Fonts.swift
//  PrecioScan
//
//  Created by Félix Olivares on 10/11/17.
//  Copyright © 2017 Felix Olivares. All rights reserved.
//

import UIKit

class Fonts: NSObject {

    func ubuntuMedium(size: CGFloat) -> UIFont {
        return UIFont(name: Font.ubuntuMediumFont, size: size)!
    }
    
    func ubuntuRegular(size: CGFloat) -> UIFont {
        return UIFont(name: Font.ubuntuRegularFont, size: size)!
    }
    
    func ubuntuBold(size: CGFloat) -> UIFont {
        return UIFont(name: Font.ubuntuBoldFont, size: size)!
    }
    
}
