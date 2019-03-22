//
//  TempStore.swift
//  PrecioScan
//
//  Created by Félix Olivares on 29/11/17.
//  Copyright © 2017 Felix Olivares. All rights reserved.
//

import UIKit

class TempStore: NSObject {

    public var name: String
    public var location: String
    public var state: String
    public var city: String
    public var uid: String
    
    public init(name: String, location: String, state: String, city: String, uid: String) {
        self.name = name
        self.location = location
        self.state = state
        self.city = city
        self.uid = uid
        super.init()
    }
}
