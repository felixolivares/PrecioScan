//
//  SubscriptionViewController.swift
//  PrecioScan
//
//  Created by Félix Olivares on 13/12/17.
//  Copyright © 2017 Felix Olivares. All rights reserved.
//

import UIKit
import DynamicButton

class SubscriptionViewController: UIViewController {

    @IBOutlet weak var hamburgerButton: DynamicButton!
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
    @IBAction func hamburgerButtonPressed(_ sender: Any) {
        if !openedWithModal{
            hamburgerButton.setStyle(.close, animated: true)
            (self.navigationController as! NavigationSubscriptionViewController).showSideMenu()
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func configure(){
    }
    
    func configureComponents(){
        UserManager.shared.verifyUserIsLogged(vc: self)
        if openedWithModal{
            hamburgerButton.setStyle(.close, animated: false)
        } else {
            hamburgerButton.setStyle(.hamburger, animated: true)
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
