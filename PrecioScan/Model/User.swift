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
    
    @NSManaged public var uid: String?
    @NSManaged public var name: String
    @NSManaged public var email: String
    @NSManaged public var password: String?
    @NSManaged public var photoName: String?
    @NSManaged public var state: String?
    @NSManaged public var city: String?
    @NSManaged public var isLogged: Bool
    @NSManaged public var isSuscribed: Bool
    @NSManaged public var itemList: NSSet 
    
    public init (context: NSManagedObjectContext, email: String, password: String?, name: String, photoName: String?, isLogged: Bool, uid: String?, isSuscribed: Bool? = nil, state: String?, city: String?){
        super.init(entity: User.entity(context: context), insertInto: context)
        self.name = name
        self.email = email
        self.password = password
        self.photoName = photoName
        self.state = state
        self.city = city
        self.isLogged = isLogged
        if isSuscribed != nil {
          self.isSuscribed = isSuscribed!
        }
        self.uid = uid
    }
    
    public class func create(_ context: NSManagedObjectContext, name: String, email: String, password: String?, photoName: String?, isLogged: Bool, uid: String?, isSuscribed: Bool, state: String?, city: String?) -> User {
        return User(context: context, email: email, password: password, name: name, photoName: photoName, isLogged: isLogged, uid: uid, isSuscribed: isSuscribed, state: state, city: city)
    }
    //email: String, password: String?, name: String, photoName: String?, isLogged: Bool, uid: String?
    func update(_ name: String? = nil, photoName: String? = nil, isLogged: Bool? = nil, isSuscribed: Bool? = nil, state: String? = nil, city: String? = nil) -> User{
        if name != nil{
            self.name = name!
        }
        if photoName != nil{
            self.photoName = photoName!
        }
        if isLogged != nil{
            self.isLogged = isLogged!
        }
        if isSuscribed != nil {
            self.isSuscribed = isSuscribed!
        }
        
        if state != nil{
            self.state = state!
        }
        
        if city != nil {
            self.city = city! 
        }
        return self
    }
    
    @objc
    private override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
}
