//
//  Button.swift
//  PrecioScan
//
//  Created by Félix Olivares on 09/10/17.
//  Copyright © 2017 Felix Olivares. All rights reserved.
//

import UIKit

class Button: UIButton {

    func setAddButton(){
        self.layer.cornerRadius = self.frame.height / 2;
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor(oliveGreen)?.cgColor;
        self.backgroundColor = UIColor(oliveGreen)
        self.tintColor = UIColor.white
    }

}
