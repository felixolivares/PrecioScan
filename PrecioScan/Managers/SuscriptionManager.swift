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
            Popup.showPurchase(title: Constants.Popup.Titles.premium, message: message, vc: vc, completionHandler: { response in
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
}
