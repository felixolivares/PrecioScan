//
//  CompareOperations.swift
//  PrecioScan
//
//  Created by Félix Olivares on 25/10/17.
//  Copyright © 2017 Felix Olivares. All rights reserved.
//

import UIKit

class CompareOperations: NSObject {
    
    public func getItemLists(byArticleCode code: String, completionHandler: @escaping([String], [[ItemList]]) -> Void){
        CoreDataManager.shared.itemLists(byArticleCode: code){ itemListsRetrieved, error in
            if let items = itemListsRetrieved{
                for eachItem in items{
                    print("Price: \(eachItem.unitaryPrice) - Store: \(eachItem.store.name) - Article Name: \(eachItem.article.name)")
                }
                let itemsGrouped = Dictionary(grouping: items, by: { $0.store.name })
                print(itemsGrouped)
                let keys = Array(itemsGrouped.keys)
                var itemsSeparated: [[ItemList]] = []
                for eachKey in keys{
                    itemsSeparated.append(itemsGrouped[eachKey]!.sorted{$0.date.compare($1.date as Date) == ComparisonResult.orderedDescending})
                }
                completionHandler(keys, itemsSeparated)
            }
        }
    }
    
    public func verifyMultipleItemListSaved(withObject object: Article, completionHandler: @escaping(Bool) -> Void){
        CoreDataManager.shared.articles(findWithCode: object.code){_, articlesRetrieved, error in
            if let articles = articlesRetrieved{
                if let article = articles.first{
                    if article.itemList.count >= 1{
                        completionHandler(true)
                    }else{
                        completionHandler(false)
                    }
                }
            }
        }
    }
    
    public func getArticleAveragePrice(withCode code: String, completionHandler:@escaping(String) -> Void){
        CoreDataManager.shared.itemLists(byArticleCode: code){ itemListsRetrieved, error in
            if let items = itemListsRetrieved, items.count > 0 {
                var sum = Float()
                for eachItem in items{
                    sum += Float(truncating: eachItem.unitaryPrice)
                    print("Price: \(eachItem.unitaryPrice) - Store: \(eachItem.store.name) - Article Name: \(eachItem.article.name)")
                }
                completionHandler("$ " + (sum / Float(items.count)).formatDecimals())
            } else {
                completionHandler("--")
            }
        }
    }
    public func formatPrice(withDecimalNumber price:NSDecimalNumber) -> String{
        let decimal = String(format:"%.2f", Double(truncating: price)).decimal /
            pow(10, Formatter.currency.maximumFractionDigits)
        return Formatter.currency.string(for: decimal)!
    }
}
