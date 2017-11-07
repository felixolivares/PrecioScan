//
//  ItemList.swift
//  PrecioScan
//
//  Created by Félix Olivares on 05/10/17.
//  Copyright © 2017 Felix Olivares. All rights reserved.
//

import Foundation
import CoreData
import JSQCoreDataKit

public final class ItemList: NSManagedObject, CoreDataEntityProtocol{
    
    public static let defaultSortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
    
    @NSManaged public var date: NSDate
    @NSManaged public var photoName: String?
    @NSManaged public var quantity: Int32
    @NSManaged public var totalPrice: NSDecimalNumber
    @NSManaged public var unitaryPrice: NSDecimalNumber
    @NSManaged public var article: Article
    @NSManaged public var list: List
    @NSManaged public var store: Store
    
    public init (context: NSManagedObjectContext, date: NSDate, photoName: String?, quantity: Int32, totalPrice: NSDecimalNumber, unitaryPrice: NSDecimalNumber, article: Article, list: List, store: Store){
        super.init(entity: ItemList.entity(context: context), insertInto: context)
        self.date = date
        self.photoName = photoName
        self.quantity = quantity
        self.totalPrice = totalPrice
        self.unitaryPrice = unitaryPrice
        self.article = article
        self.list = list
        self.store = store
    }
    
    public class func create(_ context: NSManagedObjectContext, date: Date, photoName: String?, quantity: Int32, unitaryPrice: Decimal, article: Article, list: List, store: Store) -> ItemList{
        let totalPrice = Decimal(quantity) * (unitaryPrice as Decimal)
        return ItemList(context: context, date: date as NSDate, photoName: photoName, quantity: quantity, totalPrice: totalPrice as NSDecimalNumber, unitaryPrice: unitaryPrice as NSDecimalNumber, article: article, list: list, store: store)
    }
    
    func update(_ date: Date, photoName: String?, quantity: Int32, unitaryPrice: Decimal, article: Article, list: List, store: Store) -> ItemList{
        let totalPrice = Decimal(quantity) * (unitaryPrice as Decimal)
        self.date = date as NSDate
        self.photoName = photoName
        self.quantity = quantity
        self.totalPrice = totalPrice as NSDecimalNumber
        self.unitaryPrice = unitaryPrice as NSDecimalNumber
        self.article = article
        self.list = list
        self.store = store
        return self
    }
    
    public func debug(){
        let debugString = "------ Item List -------\nArticle Name: \(self.article.name)\nDate: \(self.date)\nQuantity: \(self.quantity)\nUnitary Price: \(self.unitaryPrice)\nTotal Price: \(self.totalPrice)\nList Name: \(self.list.name)\nStore Name: \(self.store.name)\n"
        print(debugString)
    }
    
    @objc
    private override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
}
