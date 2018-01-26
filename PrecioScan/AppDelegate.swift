//
//  AppDelegate.swift
//  PrecioScan
//
//  Created by Félix Olivares on 04/10/17.
//  Copyright © 2017 Felix Olivares. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import Firebase
import SwiftyStoreKit
import GoogleMobileAds

let persistentContainer = CoreDataManager.shared

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        _ = CoreDataManager.shared
        _ = ConfigurationManager.shared
        _ = FilesManager.shared
        _ = AdsManager.shared
        
        FirebaseApp.configure()
        Popup.setupPopup()

        IQKeyboardManager.sharedManager().enable = true
        
        SwiftyStoreKit.completeTransactions(atomically: true) { purchases in
            for purchase in purchases {
                switch purchase.transaction.transactionState {
                case .purchased, .restored:
                    if purchase.needsFinishTransaction {
                        // Deliver content from server, then:
                        SwiftyStoreKit.finishTransaction(purchase.transaction)
                    }
                // Unlock content
                    print("Purchase: \(purchase)")
                case .failed, .purchasing, .deferred:
                    break // do nothing
                }
            }
        }
        InAppPurchasesManager.shared.retrieveProducts()
        GADMobileAds.configure(withApplicationID: Constants.Admob.appID)

        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        UserManager.shared.verifyConnection(){ connected in
            print("[AppDelegate] - willEnterForeground: Internet connection status: \(connected)")
        }
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

