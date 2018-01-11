//
//  ProfileViewController.swift
//  PrecioScan
//
//  Created by Félix Olivares on 10/01/18.
//  Copyright © 2018 Felix Olivares. All rights reserved.
//

import UIKit
import DynamicButton
import InteractiveSideMenu

class ProfileViewController: UIViewController, SideMenuItemContent {

    @IBOutlet weak var hamburgerButton: DynamicButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureComponents()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        hamburgerButton.setStyle(.hamburger, animated: true)
    }
    
    @IBAction func hamburgerButtonPressed(_ sender: Any) {
        hamburgerButton.setStyle(.close, animated: true)
        self.showSideMenu()
    }
    
    func configureComponents(){
        UserManager.shared.verifyUserIsLogged(vc: self)
        hamburgerButton.setStyle(.hamburger, animated: false)
    }
}
