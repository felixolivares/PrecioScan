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
    
    public static let defaultSortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
    
    @NSManaged public var date: NSDate
    @NSManaged public var name: String
    @NSManaged public var itemList: NSSet
    @NSManaged public var store: Store?
    
    public init (context: NSManagedObjectContext, date: NSDate, name: String, store: Store?){
        super.init(entity: List.entity(context: context), insertInto: context)
        self.name = name
        self.date = date
        self.store = store
    }
    
    public class func create(_ context: NSManagedObjectContext, name: String, date: Date, store: Store?) -> List{
        return List(context: context, date: date as NSDate, name: name, store: store)
    }
    
    public func debug(){
        let debugString = "------ List ------\nName: \(self.name)\nDate: \(self.date)\nStore: \(String(describing: store?.name))"
        print(debugString)
    }
    
    @objc
    private override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
}

