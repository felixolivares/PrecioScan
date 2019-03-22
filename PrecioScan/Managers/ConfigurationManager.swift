//
//  ConfigurationManager.swift
//  PrecioScan
//
//  Created by Félix Olivares on 25/10/17.
//  Copyright © 2017 Felix Olivares. All rights reserved.
//

import Foundation

class ConfigurationManager: NSObject {
    static let shared = ConfigurationManager()
    
    public static var soundEnabled: Bool? = true
    
    private override init(){
        super.init()
        ConfigurationManager.configure()
    }
    
    static func configure(){
        soundEnabled = restoreSoundEnabled()
    }
    
    public func saveSoundEnabled(completed: Bool? = true){
        UserDefaults.standard.setValue(completed, forKey: Constants.Configuration.soundEnable)
        ConfigurationManager.soundEnabled = completed
    }
    
    private static func restoreSoundEnabled() -> Bool{
        guard let temp = UserDefaults.standard.object(forKey: Constants.Configuration.soundEnable) as? Bool else { return true}
        return temp
    }
}
