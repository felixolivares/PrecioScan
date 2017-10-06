//
//  List.swift
//  PrecioScan
//
//  Created by Félix Olivares on 05/10/17.
//  Copyright © 2017 Felix Olivares. All rights reserved.
//

import Foundation
import CoreData
import JSQCoreDataKit

public final class List: NSManagedObject, CoreDataEntityProtocol{
    
    public static let defaultSortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
    
    @NSManaged public var date: NSDate
    @NSManaged public var name: String
    @NSManaged public var itemList: NSSet
    @NSManaged public var store: Store
    
    public init (context: NSManagedObjectContext, date: NSDate, name: String, itemList: NSSet, store: Store){
        super.init(entity: List.entity(context: context), insertInto: context)
        self.name = name
        self.date = date
        self.itemList = itemList
        self.store = store
    }
    
    @objc
    private override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
}

