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
    @NSManaged public var uid: String
    @NSManaged public var state: String
    @NSManaged public var city: String
    @NSManaged public var itemList: NSSet
    @NSManaged public var list: NSSet
    
    public init (context: NSManagedObjectContext, name: String, information: String? = nil, location: String, uid: String, state: String, city: String){
        super.init(entity: Store.entity(context: context), insertInto: context)
        self.name = name
        self.information = information
        self.location = location
        self.uid = uid
        self.state = state
        self.city = city
    }
    
    public class func create(_ context: NSManagedObjectContext, name: String, location: String, information: String? = nil, uid: String, state: String, city: String) -> Store {
        return Store(context: context, name: name, information: information, location: location, uid: uid, state: state, city: city)
    }
    
    public func delete(_ context: NSManagedObjectContext, completionHandler: @escaping(Bool, Error?) -> Void){
        context.delete(self)
        do {
            try context.save()
            completionHandler(true, nil)
        } catch {
            completionHandler(false, NSError(type: ErrorType.cannotSaveInCoreData))
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        
//        context.save{ result in
//            switch result{
//            case .success:
//                completionHandler(true, nil)
//            case .failure:
//                completionHandler(false, NSError(type: ErrorType.cannotSaveInCoreData))
//            }
//        }
    }
    
    public func update(name: String? = nil, location: String? = nil, information: String? = nil, uid: String? = nil, state: String? = nil, city: String? = nil) -> Store{
        if name != nil{
            self.name = name!
        }
        if location != nil{
            self.location = location!
        }
        if information != nil{
            self.information = information
        }
        if uid != nil{
            self.uid = uid!
        }
        if state != nil{
            self.state = state!
        }
        if city != nil{
            self.city = city!
        }
        return self
    }
    
    @objc
    private override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
}

