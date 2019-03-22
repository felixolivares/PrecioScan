//
//  InAppPurchasesManager.swift
//  PrecioScan
//
//  Created by Félix Olivares on 19/01/18.
//  Copyright © 2018 Felix Olivares. All rights reserved.
//

import UIKit
import SwiftyStoreKit
import StoreKit

protocol InAppPurchasesDelegate{
    func connectionChanged(withConnectionStatus connected:Bool, productPrice: String?)
}

class InAppPurchasesManager: NSObject {
    
    static let shared = InAppPurchasesManager()
    var productPriceString: String = ""
    var product:SKProduct? = nil
    var delegate: InAppPurchasesDelegate?
    
    private override init(){
        super.init()
        configure()
    }
    
    private func configure(){
        print("In App Purchase manager configured")
        verifyConnectionAndRetrieveProduct()
    }
    
    public func verifyConnectionAndRetrieveProduct(){
        UserManager.shared.verifyConnection(){ connected in
            print("[InAppPurchasesManager] - Configure: Internet connection status: \(connected)")
            if connected {
                self.retrieveProducts(completionHandler: { product, error in
                    if product != nil {
                        self.delegate?.connectionChanged(withConnectionStatus: true, productPrice: product?.localizedPrice)
                    }
                })
            }
        }
    }
    
    public func retrieveProducts(){
        SwiftyStoreKit.retrieveProductsInfo([Constants.InAppPurchasesManager.product]) { result in
            if let product = result.retrievedProducts.first {
                self.product = product
                let priceString = product.localizedPrice!
                self.productPriceString = priceString
                print("[InAppPurchasesManager] - retrieveProducts: Product: \(product.localizedDescription), price: \(priceString)")
            }
            else if let invalidProductId = result.invalidProductIDs.first {
                print("[InAppPurchasesManager] - retrieveProducts: Invalid product identifier: \(invalidProductId)")
            }
            else {
                print("[InAppPurchasesManager] - retrieveProducts: Error: \(String(describing: result.error))")
            }
        }
    }
    
    public func retrieveProducts(completionHandler: @escaping(SKProduct?, Error?) -> Void){
        SwiftyStoreKit.retrieveProductsInfo([Constants.InAppPurchasesManager.product]) { result in
            if let product = result.retrievedProducts.first {
                self.product = product
                let priceString = product.localizedPrice!
                self.productPriceString = priceString
                completionHandler(product, nil)
                print("[InAppPurchasesManager] - retrieveProducts:completionHandler: Product: \(product.localizedDescription), price: \(priceString)")
            }
            else if let invalidProductId = result.invalidProductIDs.first {
                print("[InAppPurchasesManager] - retrieveProducts:completionHandler Invalid product identifier: \(invalidProductId)")
                completionHandler(nil, nil)
            }
            else {
                print("[InAppPurchasesManager] - retrieveProducts:completionHandler Error: \(String(describing: result.error))")
                completionHandler(nil, result.error)
            }
        }
    }
    
    public func purchasePremium(completionHandler: @escaping(Bool, SKError?) -> Void){
        guard self.product != nil else {return}
        SwiftyStoreKit.purchaseProduct(self.product!, quantity: 1, atomically: true) { result in
            print(result)
            switch result {
            case .success(let purchase):
                print("Purchase Success: \(purchase.productId)")
                self.updateUserSubscription(isSubscribed: true, purchaseDate: DateOperations().getCurrentLocalDate())
                completionHandler(true, nil)
            case .error(let error):
                completionHandler(false, error)
                switch error.code {
                case .unknown: print("Unknown error. Please contact support")
                case .clientInvalid: print("Not allowed to make the payment")
                case .paymentCancelled: break
                case .paymentInvalid: print("The purchase identifier was invalid")
                case .paymentNotAllowed: print("The device is not allowed to make the payment")
                case .storeProductNotAvailable: print("The product is not available in the current storefront")
                case .cloudServicePermissionDenied: print("Access to cloud service information is not allowed")
                case .cloudServiceNetworkConnectionFailed: print("Could not connect to the network")
                case .cloudServiceRevoked: print("User has revoked permission to use this cloud service")
                }
            }
        }
    }
    
    public func restorePurchase(completionHandler: @escaping(Bool?, SKError?) -> Void){
        SwiftyStoreKit.restorePurchases(atomically: true) { results in
            if results.restoreFailedPurchases.count > 0 {
                print("Restore Failed: \(results.restoreFailedPurchases)")
                completionHandler(false, results.restoreFailedPurchases.first?.0)
            }
            else if results.restoredPurchases.count > 0 {
                print("Restore Success: \(results.restoredPurchases)")
                self.updateUserSubscription(isSubscribed: true, purchaseDate: DateOperations().getCurrentLocalDate())
                completionHandler(true, nil)
            }
            else {
                print("Nothing to Restore")
                completionHandler(nil, nil)
            }
        }
    }
    
    private func updateUserSubscription(isSubscribed: Bool, purchaseDate: Date){
        persistentContainer.updateUserSubscription(object: UserManager.shared.getCurrentUser()!, isSubscribed: isSubscribed, completionHandler: { finished, error in
            if finished {
                print("User updated")
                FirebaseOperations().updateCurrentUser(withSubscriptionDate: purchaseDate, isSubscribed: isSubscribed)
            }
        })
    }
}
