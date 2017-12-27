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
    }
    @IBAction func hamburgerButtonPressed(_ sender: Any) {
        hamburgerButton.setStyle(.close, animated: true)
        (self.navigationController as! NavigationSubscriptionViewController).showSideMenu()
    }
    
    func configureComponents(){
        UserManager.shared.verifyUserIsLogged(vc: self)
        hamburgerButton.setStyle(.hamburger, animated: true)
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
