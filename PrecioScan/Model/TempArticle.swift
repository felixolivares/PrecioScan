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
    public var suggestedPrice: Decimal?
    
    public init(code: String, name: String, uid: String, suggestedPrice: Decimal? = nil){
        self.code = code
        self.name = name
        self.uid = uid
        self.suggestedPrice = suggestedPrice
        super.init()
    }
}
