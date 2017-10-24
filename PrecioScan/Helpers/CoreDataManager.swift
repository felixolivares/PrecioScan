//
//  CoreDataManager.swift
//  PrecioScan
//
//  Created by Félix Olivares on 10/10/17.
//  Copyright © 2017 Felix Olivares. All rights reserved.
//

import UIKit
import CoreData
import JSQCoreDataKit

class CoreDataManager: NSObject, NSFetchedResultsControllerDelegate {
    static let shared = CoreDataManager()
    
    private let model = CoreDataModel(name: modelName, bundle: modelBundle)
    private var fetchResultControllerStore: NSFetchedResultsController<Store>!
    private var stack: CoreDataStack!
    
    private override init(){
        super.init()
        configure()
    }
    
    func configure(){
        createStack()
    }
    
    public func getFactory() -> CoreDataStackFactory{
        return CoreDataStackFactory(model: model)
    }
    
    public func getStack() -> CoreDataStack?{
        return self.stack
    }
    
    func createStack(){
        guard self.stack == nil else {return}
        getFactory().createStack{ (result: StackResult) -> Void in
            switch result {
            case .success(let s):
                self.stack = s
            case .failure(let err):
                assertionFailure("Error creating stack: \(err)")
            }
        }
    }
    
    func createStack(withCompletion completionHandler: @escaping(Bool) -> Void){
        guard self.stack == nil else {return}
        getFactory().createStack{ (result: StackResult) -> Void in
            switch result {
            case .success(let s):
                self.stack = s
                completionHandler(true)
            case .failure(let err):
                assertionFailure("Error creating stack: \(err)")
                completionHandler(false)
            }
        }
    }
    
    //MARK: - Stores
    public func stores(completionHandler: @escaping(CoreDataStack?, [Store]?, Error?) -> Void){
        var fetchResultController: NSFetchedResultsController<Store>!
        guard self.stack != nil else { completionHandler(nil, nil, NSError(type: ErrorType.cannotSaveInCoreData)); return }
        fetchResultController = NSFetchedResultsController(fetchRequest: Store.fetchRequest,
                                                           managedObjectContext: stack!.mainContext,
                                                           sectionNameKeyPath: nil,
                                                           cacheName: nil)
        fetchResultController.delegate = self
        do {
            try fetchResultController.performFetch()
            print("Store objects count \(String(describing: fetchResultController.fetchedObjects?.count))")
            completionHandler(stack, fetchResultController.fetchedObjects, nil)
        } catch {
            assertionFailure("Failed to fetch: \(error)")
            completionHandler(nil, nil, error)
        }
    }
    
    public func saveStore(name: String, location: String, information: String?, completionHandler: @escaping(Store?, Error?) -> Void) {
        stack.mainContext.performAndWait {
            let storeSaved = Store.create(stack.mainContext, name: name, location: location, information: information)
            saveContext(stack.mainContext){ result in
                switch result{
                case .success:
                    completionHandler(storeSaved, nil)
                case .failure:
                    completionHandler(nil, NSError(type: ErrorType.cannotSaveInCoreData))
                }
            }
            
        }
    }
    
    
    //MARK: - Articles
    public func articles(findWithCode code: String?, completionHandler: @escaping(CoreDataStack?, [Article]?, Error?) -> Void){
        var fetchRequest: NSFetchRequest<Article>!
        if code != nil{
            fetchRequest = Article.fetchRequest
            fetchRequest.predicate = NSPredicate(format: "code == %@", code!)
        }else{
            fetchRequest = Article.fetchRequest
        }
        var fetchResultController: NSFetchedResultsController<Article>!
        guard self.stack != nil else { completionHandler(nil, nil, NSError(type: ErrorType.cannotSaveInCoreData)); return }
        fetchResultController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                           managedObjectContext: stack!.mainContext,
                                                           sectionNameKeyPath: nil,
                                                           cacheName: nil)
        fetchResultController.delegate = self
        do {
            try fetchResultController.performFetch()
            print("Article objects count \(String(describing: fetchResultController.fetchedObjects?.count))")
            completionHandler(stack, fetchResultController.fetchedObjects, nil)
        } catch {
            assertionFailure("Failed to fetch: \(error)")
            completionHandler(nil, nil, error)
        }
    }
    
    public func saveArticle(code: String, name: String, completionHandler: @escaping(Article?, Error?) -> Void){
        stack.mainContext.performAndWait {
            let article = Article.create(stack.mainContext, name: name, code: code)
            saveContext(stack.mainContext){ result in
                switch result{
                case .success:
                    completionHandler(article, nil)
                case .failure:
                    completionHandler(nil, NSError(type: ErrorType.cannotSaveInCoreData))
                }
            }
        }
    }
    
    //MARK: - ItemList
    public func saveItemList(date: Date, photoName: String?, quantity: Int32, unitariPrice: Decimal, article: Article, list: List, store: Store, completionHandler: @escaping(ItemList?, Error?) -> Void){
        stack.mainContext.performAndWait {
            let itemList = ItemList.create(stack.mainContext, date: date, photoName: photoName, quantity: quantity, unitaryPrice: unitariPrice, article: article, list: list, store: store)
            saveContext(stack.mainContext){ result in
                switch result{
                case .success:
                    completionHandler(itemList, nil)
                case .failure:
                    completionHandler(nil, NSError(type: ErrorType.cannotSaveInCoreData))
                }
            }
        }
    }
    
    public func itemLists(withList list: List?, completionHandler: @escaping(CoreDataStack?, [ItemList]?, NSError?) -> Void){
        var fetchRequest: NSFetchRequest<ItemList>
        if let list = list{
            fetchRequest = ItemList.fetchRequest
            fetchRequest.predicate = NSPredicate(format: "list == %@", list)
        }else{
            fetchRequest = ItemList.fetchRequest
        }
        var fetchResultController: NSFetchedResultsController<ItemList>!
        guard self.stack != nil else { completionHandler(nil, nil, NSError(type: ErrorType.cannotSaveInCoreData)); return }
        fetchResultController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                           managedObjectContext: stack!.mainContext,
                                                           sectionNameKeyPath: nil,
                                                           cacheName: nil)
        fetchResultController.delegate = self
        do {
            try fetchResultController.performFetch()
            print("Item List objects count \(String(describing: fetchResultController.fetchedObjects?.count))")
            completionHandler(stack, fetchResultController.fetchedObjects, nil)
        } catch {
            assertionFailure("Failed to fetch: \(error)")
            completionHandler(nil, nil, error as NSError)
        }
    }
    
    //MARK: - List
    public func saveList(name: String, date: Date, store: Store?, completionHandler: @escaping(List?, Error?) -> Void){
        stack.mainContext.performAndWait {
            let list = List(context: stack.mainContext, date: date as NSDate, name: name, store: store)
            saveContext(stack.mainContext){ result in
                switch result{
                case .success:
                    completionHandler(list, nil)
                case .failure:
                    completionHandler(nil, NSError(type: ErrorType.cannotSaveInCoreData))
                }
            }
        }
    }
    
    public func lists(completionHandler: @escaping(CoreDataStack?, [List]?, Error?) -> Void){
        var fetchResultController: NSFetchedResultsController<List>!
        guard self.stack != nil else { configure(); return }
        fetchResultController = NSFetchedResultsController(fetchRequest: List.fetchRequest,
                                                           managedObjectContext: stack!.mainContext,
                                                           sectionNameKeyPath: nil,
                                                           cacheName: nil)
        fetchResultController.delegate = self
        do {
            try fetchResultController.performFetch()
            print("List objects count \(String(describing: fetchResultController.fetchedObjects?.count))")
            completionHandler(stack, fetchResultController.fetchedObjects, nil)
        } catch {
            assertionFailure("Failed to fetch: \(error)")
            completionHandler(nil, nil, error)
        }
    }
}
