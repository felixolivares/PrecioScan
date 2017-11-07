//
//  UserManager.swift
//  PrecioScan
//
//  Created by Félix Olivares on 07/11/17.
//  Copyright © 2017 Felix Olivares. All rights reserved.
//

import UIKit

class UserManager: NSObject {
    static let shared = UserManager()
    
    public static var userLoggedIn: Bool? = false
    
    private override init(){
        super.init()
        configure()
    }
    
    func configure(){
        
    }
}


