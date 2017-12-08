//
//  TempArticle.swift
//  PrecioScan
//
//  Created by Félix Olivares on 02/12/17.
//  Copyright © 2017 Felix Olivares. All rights reserved.
//

import UIKit

class TempArticle: NSObject {
   
    public var code: String
    public var name: String
    public var uid: String
    
    public init(code: String, name: String, uid: String){
        self.code = code
        self.name = name
        self.uid = uid
        super.init()
    }
}
