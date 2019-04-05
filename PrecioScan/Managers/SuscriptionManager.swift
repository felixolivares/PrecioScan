//
//  SuscriptionManager.swift
//  PrecioScan
//
//  Created by Félix Olivares on 05/01/18.
//  Copyright © 2018 Felix Olivares. All rights reserved.
//

import UIKit

class SuscriptionManager: NSObject {
    static let shared = SuscriptionManager()
    
    enum SubscriptionStatus{
        case Subscribed
        case NotSubscribed
    }
    
    private override init(){
        super.init()
        self.configure()
    }
    
    func configure(){
        
    }
    
    func promptToSubscribe(vc: UIViewController, message: String, completionHandler: @escaping(Bool, SubscriptionStatus) -> Void){
        if !UserManager.shared.userIsSuscribed(){
            let finalMessage = message.replacingOccurrences(of: "$productPrice", with: InAppPurchasesManager.shared.productPriceString)
            Popup.showPurchase(title: Constants.Popup.Titles.premium, message: finalMessage, vc: vc, completionHandler: { response in
                if response == PopupResponse.Accept{
                    completionHandler(true, SubscriptionStatus.NotSubscribed)
                } else {
                    completionHandler(false, SubscriptionStatus.NotSubscribed)
                }
            })
        } else {
            completionHandler(true, SubscriptionStatus.Subscribed)
        }
    }
    
    func promptToSubscribeWithRewarded(vc: UIViewController, message: String, completionHandler: @escaping(String, SubscriptionStatus) -> Void){
        if !UserManager.shared.userIsSuscribed(){
            let finalMessage = message.replacingOccurrences(of: "$productPrice", with: InAppPurchasesManager.shared.productPriceString)
            Popup.showPurchaseRewarded(title: Constants.Popup.Titles.premium, message: finalMessage, vc: vc, completionHandler: { response in
                completionHandler(response, SubscriptionStatus.NotSubscribed)
            })
        } else {
            completionHandler(PopupResponse.Accept, SubscriptionStatus.Subscribed)
        }
    }
}
