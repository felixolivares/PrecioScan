//
//  Article.swift
//  PrecioScan
//
//  Created by Félix Olivares on 05/10/17.
//  Copyright © 2017 Felix Olivares. All rights reserved.
//

import Foundation
import CoreData
import JSQCoreDataKit

public final class Article: NSManagedObject, CoreDataEntityProtocol{
    
    public static let defaultSortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
    
    @NSManaged public var code: String
    @NSManaged public var name: String
    @NSManaged public var uid: String
    @NSManaged public var itemList: NSSet
    @NSManaged public var suggestedPrice: NSDecimalNumber
    
    public init (context: NSManagedObjectContext, code: String, name: String, uid: String, suggestedPrice: NSDecimalNumber){
        super.init(entity: Article.entity(context: context), insertInto: context)
        self.name = name
        self.code = code
        self.uid = uid
        self.suggestedPrice = suggestedPrice
    }
    
    public class func create(_ context: NSManagedObjectContext, name: String, code: String, uid: String, suggestedPrice: Decimal? = 0.0) -> Article {
        return Article(context: context, code: code, name: name, uid: uid, suggestedPrice: suggestedPrice! as NSDecimalNumber)
    }
    
    func update(name: String? = nil, uid: String? = nil, suggestedPrice: Decimal? = nil) -> Article {
        if name != nil{
            self.name = name!
        }
        if uid != nil{
            self.uid = uid!
        }
        if suggestedPrice != nil{
            self.suggestedPrice = suggestedPrice! as NSDecimalNumber
        }
        return self
    }
    
    public func debug(){
        let debugString = "------ Article ------\nName: \(self.name)\nUid: \(self.uid)\nCode: \(self.code))\nSuggesteedPrice: \(self.suggestedPrice))"
        print(debugString)
    }
    
    @objc
    private override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
}
