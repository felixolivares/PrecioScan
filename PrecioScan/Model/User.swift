//
//  User.swift
//  PrecioScan
//
//  Created by Félix Olivares on 07/11/17.
//  Copyright © 2017 Felix Olivares. All rights reserved.
//

import Foundation
import CoreData
import JSQCoreDataKit

public final class User: NSManagedObject, CoreDataEntityProtocol {

    public static let defaultSortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
    
    @NSManaged public var name: String
    @NSManaged public var email: String
    @NSManaged public var password: String?
    @NSManaged public var photoName: String?
    @NSManaged public var isLogged: Bool
    @NSManaged public var itemList: NSSet 
    
    public init (context: NSManagedObjectContext, email: String, password: String?, name: String, photoName: String?, isLogged: Bool){
        super.init(entity: User.entity(context: context), insertInto: context)
        self.name = name
        self.email = email
        self.password = password
        self.photoName = photoName
        self.isLogged = isLogged
    }
    
    public class func create(_ context: NSManagedObjectContext, name: String, email: String, password: String?, photoName: String?, isLogged: Bool) -> User {
        return User(context: context, email: email, password: password, name: name, photoName: photoName, isLogged: isLogged)
    }
    
    func update(_ name: String, email: String, password: String?, photoName: String?, isLogged: Bool) -> User{
        self.name = name
        self.email = email
        self.password = password
        self.photoName = photoName
        self.isLogged = isLogged
        return self
    }
    
    @objc
    private override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
}
