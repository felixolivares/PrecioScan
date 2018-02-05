//
//  PageFour.swift
//  PrecioScan
//
//  Created by Félix Olivares on 18/01/18.
//  Copyright © 2018 Felix Olivares. All rights reserved.
//

import UIKit
import SwiftyOnboard
import StoreKit

class PageFour: SwiftyOnboardPage, InAppPurchasesDelegate {

    @IBOutlet weak var buyButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var backgroundFadeView: UIView!
    @IBOutlet weak var continueButtonBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var continueButton: RoundedButton!
    @IBOutlet weak var logoImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var logoTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var crownIcon: UIImageView!
    @IBOutlet weak var titleTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var activityIndicatore: UIActivityIndicatorView!
    @IBOutlet weak var activityIndicatorPurchasing: UIActivityIndicatorView!
    
    class func instanceFromNib() -> UIView {
//        NotificationCenter.default.addObserver(self, selector: #selector(self.connectionChanged(notification:)), name: Notification.Name(Identifiers.Notifications.connectionChanged), object: nil)
        return UINib(nibName: "PageFour", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
    }
    
    func configure(){
        InAppPurchasesManager.shared.delegate = self
    }

    @IBAction func buyButtonPressed(_ sender: Any) {
        print("Buy button presed ")
        activityIndicatorPurchasing.startAnimating()
        activityIndicatorPurchasing.alpha = 1.0
        UserManager.shared.verifyConnection(){ connected in
            if connected {
                if InAppPurchasesManager.shared.product != nil {
                    InAppPurchasesManager.shared.purchasePremium(){ purchaseComplete, error in
                        if purchaseComplete{
                            self.activityIndicatore.startAnimating()
                            self.purchaseFade()
                        } else {
                            Popup.show(withError: error! as NSError, vc: self.viewController()!)
                            self.activityIndicatorPurchasing.stopAnimating()
                        }
                    }
                } else {
                    self.showRetryConnection()
                }
            } else {
                self.showRetryConnection()
            }
        }
    }
    
    @IBAction func restoreButtonPressed(_ sender: Any) {
        print("Restore button presed ")
        activityIndicatorPurchasing.startAnimating()
        activityIndicatorPurchasing.alpha = 1.0
        UserManager.shared.verifyConnection(){ connected in
            if connected {
                InAppPurchasesManager.shared.restorePurchase(completionHandler: { finished, error in
                    if let success = finished, success {
                        self.activityIndicatore.startAnimating()
                        self.purchaseFade()
                    }else if let success = finished, !success, let purchaseError = error {
                        Popup.show(withError: purchaseError as NSError, vc: self.viewController()!)
                        self.activityIndicatorPurchasing.stopAnimating()
                    }
                })
            } else {
                self.showRetryConnection()
            }
        }
    }
    
    @IBAction func continueButtonPressed(_ sender: Any) {
        (self.viewController() as! SubscriptionViewController).continueButtonPressed()
    }
    
    @objc func connectionChanged(notification: Notification){
        if let productPrice = (notification.userInfo?[Identifiers.productIdentifier] as? String) {
            if productPrice != ""{
                setButtonTitle(title: Constants.Subscription.buyButtonTitle + productPrice)
            } else {
                setButtonTitle(title: "")
                activityIndicator.startAnimating()
            }
        }
    }
    
    func showRetryConnection(){
        activityIndicatorPurchasing.stopAnimating()
        activityIndicatorPurchasing.alpha = 0
        Popup.showRetryConnection(title: Constants.Popup.Titles.attention, message: Warning.Generic.networkError, vc: self.viewController()!, completionHandler: { response in
            if response == PopupResponse.Accept {
                InAppPurchasesManager.shared.verifyConnectionAndRetrieveProduct()
            }
        })
    }
    
    func setButtonTitle(title: String){
        self.buyButton.setTitle(title, for: .normal)
        activityIndicator.stopAnimating()
    }
    
    func purchaseFade(){
        UIView.animate(withDuration: 0.3, animations: {
            self.backgroundFadeView.alpha = 1.0
        }, completion: { finished in
            let when = DispatchTime.now() + 5
            DispatchQueue.main.asyncAfter(deadline: when) {
                self.activityIndicatore.stopAnimating()
                UIView.animate(withDuration: 0.3, animations: {
                    self.logoImage.alpha = 1.0
                    self.logoTopConstraint.constant = 85.0
                    self.backgroundFadeView.layoutIfNeeded()
                }, completion: { finished in
                    UIView.animate(withDuration: 0.3, animations: {
                        self.crownIcon.alpha = 1
                        self.crownIcon.bounce()
                    }, completion: { finished in
                        UIView.animate(withDuration: 0.3, animations: {
                            self.titleTopConstraint.constant = 35
                            self.backgroundFadeView.layoutIfNeeded()
                            self.titleLabel.alpha = 1
                        }, completion: { finished in 
                            
                        })
                        UIView.animate(withDuration: 0.5, animations: {
                            self.continueButtonBottomConstraint.constant = 30
                            self.backgroundFadeView.layoutIfNeeded()
                            self.continueButton.alpha = 1
                        }, completion: { finished in
                            
                        })
                    })
                })
            }
        })
    }
    
    func connectionChanged(withConnectionStatus connected: Bool, productPrice: String?) {
        if connected , let price = productPrice {
            setButtonTitle(title: Constants.Subscription.buyButtonTitle + price)
        }
    }
}


