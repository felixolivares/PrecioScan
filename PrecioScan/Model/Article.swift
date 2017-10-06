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
    @NSManaged public var itemList: NSSet
    
    public init (context: NSManagedObjectContext, code: String, name: String, itemList: NSSet){
        super.init(entity: Article.entity(context: context), insertInto: context)
        self.name = name
        self.code = code
        self.itemList = itemList
    }
    
    @objc
    private override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
}
