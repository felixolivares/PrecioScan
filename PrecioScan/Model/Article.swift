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
    
    public init (context: NSManagedObjectContext, code: String, name: String){
        super.init(entity: Article.entity(context: context), insertInto: context)
        self.name = name
        self.code = code
    }
    
    public class func create(_ context: NSManagedObjectContext, name: String, code: String) -> Article {
        return Article(context: context, code: code, name: name)
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
