//
//  TempUser.swift
//  PrecioScan
//
//  Created by Félix Olivares on 30/01/18.
//  Copyright © 2018 Felix Olivares. All rights reserved.
//

import UIKit

class TempUser: NSObject {
    public var uid: String
    public var email: String
    public var isSubscribed: Bool
    public var subscriptionDate: Double?
    public var username: String
    
    public init(email: String, isSubscribed: Bool, uid: String, subscriptionDate: Double?, username: String){
        self.email = email
        self.isSubscribed = isSubscribed
        self.uid = uid
        self.username = username
        self.subscriptionDate = subscriptionDate
        super.init()
    }
}
