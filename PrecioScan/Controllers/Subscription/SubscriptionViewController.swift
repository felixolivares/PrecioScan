//
//  SubscriptionViewController.swift
//  PrecioScan
//
//  Created by Félix Olivares on 13/12/17.
//  Copyright © 2017 Felix Olivares. All rights reserved.
//

import UIKit
import DynamicButton
import SwiftyOnboard

class SubscriptionViewController: UIViewController {

    @IBOutlet weak var swiftyOnboard: SwiftyOnboard!
    @IBOutlet weak var hamburgerButton: DynamicButton!
    @IBOutlet weak var premiumView: UIView!
    
    var openedWithModal: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureComponents()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        swiftyOnboard?.goToPage(index: 0, animated: false)
    }
    
    @IBAction func hamburgerButtonPressed(_ sender: Any) {
        if !openedWithModal{
            hamburgerButton.setStyle(.close, animated: true)
            (self.navigationController as! NavigationSubscriptionViewController).showSideMenu()
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    
    func configure(){
        swiftyOnboard.style = .light
        swiftyOnboard.delegate = self
        swiftyOnboard.dataSource = self
        swiftyOnboard.backgroundColor = UIColor.white
        swiftyOnboard.fadePages = true
    }
    
    func configureComponents(){
        premiumView.isHidden = !UserManager.shared.userIsSuscribed()
        UserManager.shared.verifyUserIsLogged(vc: self)
        if openedWithModal{
            hamburgerButton.setStyle(.close, animated: false)
        } else {
            hamburgerButton.setStyle(.hamburger, animated: true)
        }
    }
    
    @objc func continueButtonPressed(){
        if !openedWithModal{
            hamburgerButton.setStyle(.close, animated: true)
            (self.navigationController as! NavigationSubscriptionViewController).showSideMenu()
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc func handleContinue(sender: UIButton) {
        let index = sender.tag
        swiftyOnboard?.goToPage(index: index + 1, animated: true)
    }
}

extension SubscriptionViewController: SwiftyOnboardDelegate, SwiftyOnboardDataSource {
    
    func swiftyOnboardNumberOfPages(_ swiftyOnboard: SwiftyOnboard) -> Int {
        return 4
    }
    
    func swiftyOnboardPageForIndex(_ swiftyOnboard: SwiftyOnboard, index: Int) -> SwiftyOnboardPage? {
        switch index {
        case 0:
            return PageOne.instanceFromNib() as? PageOne
        case 1:
            return PageTwo.instanceFromNib() as? PageTwo
        case 2:
            return PageThree.instanceFromNib() as? PageThree
        case 3:
            let pageFour = PageFour.instanceFromNib() as? PageFour
            pageFour?.configure()
            if let product = InAppPurchasesManager.shared.product{
                pageFour?.buyButton.setTitle(Constants.Subscription.buyButtonTitle + product.localizedPrice!, for: .normal)
            } else {
//                pageFour?.buyButton.setTitle("", for: .normal)
                pageFour?.activityIndicator.startAnimating()
                InAppPurchasesManager.shared.retrieveProducts(completionHandler: { product, error in
                    if product != nil {
                        pageFour?.buyButton.setTitle(Constants.Subscription.buyButtonTitle + (product?.localizedPrice!)!, for: .normal)
                    } else {
                        Popup.showRetryConnection(title: Constants.Popup.Titles.attention, message: error?.localizedDescription, vc: self, completionHandler: { response in
                            if response == PopupResponse.Accept {
                                InAppPurchasesManager.shared.verifyConnectionAndRetrieveProduct()
                            }
                        })
                    }
                })
                //pageFour?.continueButton.addTarget(self, action: #selector(continueButtonPressed), for: .touchUpInside)
            }
            return pageFour
        default:
            return PageOne.instanceFromNib() as? PageOne
        }
    }
    
    func swiftyOnboardViewForOverlay(_ swiftyOnboard: SwiftyOnboard) -> SwiftyOnboardOverlay? {
        let overlay = CustomOverlay.instanceFromNib() as? CustomOverlay
        //overlay?.skip.addTarget(self, action: #selector(handleSkip), for: .touchUpInside)
        overlay?.buttonContinue.addTarget(self, action: #selector(handleContinue), for: .touchUpInside)
        return overlay
    }
    
    func swiftyOnboardOverlayForPosition(_ swiftyOnboard: SwiftyOnboard, overlay: SwiftyOnboardOverlay, for position: Double) {
        let overlay = overlay as! CustomOverlay
        let currentPage = round(position)
        overlay.controlPage.currentPage = Int(currentPage)
        overlay.buttonContinue.tag = Int(position)
        if currentPage == 3.0 {
            UIView.animate(withDuration: 0.2, animations: {
                overlay.controlPage.alpha = 0
            })
        } else {
            UIView.animate(withDuration: 0.3, animations: {
                overlay.controlPage.alpha = 1
            })
        }
    }
}
