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
    
    public init (context: NSManagedObjectContext, code: String, name: String, uid: String){
        super.init(entity: Article.entity(context: context), insertInto: context)
        self.name = name
        self.code = code
        self.uid = uid
    }
    
    public class func create(_ context: NSManagedObjectContext, name: String, code: String, uid: String) -> Article {
        return Article(context: context, code: code, name: name, uid: uid)
    }
    
    func update(name: String) -> Article {
        self.name = name
        return self
    }
    @objc
    private override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
}
