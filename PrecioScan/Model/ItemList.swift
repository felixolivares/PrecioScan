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
    
    @NSManaged public var uid: String
    @NSManaged public var date: NSDate
    @NSManaged public var photoName: String?
    @NSManaged public var quantity: Int32
    @NSManaged public var totalPrice: NSDecimalNumber
    @NSManaged public var unitaryPrice: NSDecimalNumber
    @NSManaged public var article: Article
    @NSManaged public var list: List
    @NSManaged public var store: Store
    @NSManaged public var user: User
    
    public init (context: NSManagedObjectContext, uid: String, date: NSDate, photoName: String?, quantity: Int32, totalPrice: NSDecimalNumber, unitaryPrice: NSDecimalNumber, article: Article, list: List, store: Store, user: User){
        super.init(entity: ItemList.entity(context: context), insertInto: context)
        self.uid = uid
        self.date = date
        self.photoName = photoName
        self.quantity = quantity
        self.totalPrice = totalPrice
        self.unitaryPrice = unitaryPrice
        self.article = article
        self.list = list
        self.store = store
        self.user = user
    }
    
    public class func create(_ context: NSManagedObjectContext, uid: String, date: Date, photoName: String?, quantity: Int32, unitaryPrice: Decimal, article: Article, list: List, store: Store, user: User) -> ItemList{
        let totalPrice = Decimal(quantity) * (unitaryPrice as Decimal)
        return ItemList(context: context, uid: uid, date: date as NSDate, photoName: photoName, quantity: quantity, totalPrice: totalPrice as NSDecimalNumber, unitaryPrice: unitaryPrice as NSDecimalNumber, article: article, list: list, store: store, user: user)
    }
    
    func update(_ date: Date? = nil, photoName: String? = nil, quantity: Int32? = nil, unitaryPrice: Decimal? = nil, article: Article? = nil, list: List? = nil, store: Store? = nil, user: User? = nil) -> ItemList{
        let totalPrice: Decimal?
        
        if date != nil{
            self.date = date! as NSDate
        }
        if photoName != nil{
            self.photoName = photoName!
        }
        if quantity != nil{
            self.quantity = quantity!
            totalPrice = Decimal(quantity!) * (unitaryPrice! as Decimal)
            self.totalPrice = totalPrice! as NSDecimalNumber
        }
        if unitaryPrice != nil{
            self.unitaryPrice = unitaryPrice! as NSDecimalNumber
        }
        if article != nil{
            self.article = article!
        }
        if list != nil{
            self.list = list!
        }
        if store != nil{
            self.store = store!
        }
        if user != nil{
            self.user = user!
        }
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
