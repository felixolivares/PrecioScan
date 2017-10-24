//
//  Store.swift
//  PrecioScan
//
//  Created by Félix Olivares on 05/10/17.
//  Copyright © 2017 Felix Olivares. All rights reserved.
//

import Foundation
import CoreData
import JSQCoreDataKit

public final class Store: NSManagedObject, CoreDataEntityProtocol, NSFetchedResultsControllerDelegate{
    
    public static let defaultSortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
    
    @NSManaged public var information: String?
    @NSManaged public var location: String
    @NSManaged public var name: String
    @NSManaged public var itemList: NSSet
    @NSManaged public var list: NSSet
    
    public init (context: NSManagedObjectContext, name: String, information: String? = nil, location: String){
        super.init(entity: Store.entity(context: context), insertInto: context)
        self.name = name
        self.information = information
        self.location = location
//        self.itemList = itemList
    }
    
    public class func create(_ context: NSManagedObjectContext, name: String, location: String, information: String? = nil) -> Store {
        return Store(context: context, name: name, information: information, location: location)
    }
    
    @objc
    private override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
}

