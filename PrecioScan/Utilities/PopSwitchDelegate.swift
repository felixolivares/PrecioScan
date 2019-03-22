//
//  PopSwitchDelegate.swift
//  PrecioScan
//
//  Created by Félix Olivares on 24/10/17.
//  Copyright © 2017 Felix Olivares. All rights reserved.
//

import Foundation
import UIKit

public protocol PopSwitchDelegate {
    func valueChanged(to state:PopSwitch.State)
}
