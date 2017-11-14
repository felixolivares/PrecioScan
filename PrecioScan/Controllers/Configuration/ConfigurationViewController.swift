//
//  ConfigurationViewController.swift
//  PrecioScan
//
//  Created by Félix Olivares on 24/10/17.
//  Copyright © 2017 Felix Olivares. All rights reserved.
//

import UIKit
import DynamicButton
import InteractiveSideMenu
import PWSwitch

class ConfigurationViewController: UIViewController, SideMenuItemContent {

    @IBOutlet weak var hamburgerButton: DynamicButton!
    @IBOutlet weak var soundSwitch: PWSwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        restoreConfigurationValues()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureComponents()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        hamburgerButton.setStyle(.hamburger, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func hamburgerButtonPressed(_ sender: Any) {
        hamburgerButton.setStyle(.close, animated: true)
        self.showSideMenu()
    }
    
    func restoreConfigurationValues(){
        soundSwitch.setOn(ConfigurationManager.soundEnabled!, animated: false)
        soundSwitch.addTarget(self, action: #selector(self.onSwitchChanged(_:)), for: .valueChanged)
        configureSwitch(sender: soundSwitch)
    }
    
    func configureSwitch(sender: PWSwitch){
        sender.trackOffBorderColor = UIColor(oliveGreen)
        sender.thumbOnFillColor = UIColor.white
        sender.thumbOnBorderColor = UIColor("9d9d9d")
        sender.trackOnFillColor = UIColor(oliveGreen)
    }
    func configureComponents(){
        UserManager.shared.verifyUserIsLogged(vc: self)
        hamburgerButton.setStyle(.hamburger, animated: false)
    }
    
    func updateSwitch(withstate state: Bool, pwSwitch: PWSwitch){
        pwSwitch.setOn(state, animated: false)
    }
    
    @objc func onSwitchChanged(_ sender:PWSwitch){
        switch sender.tag{
        case 1:
            ConfigurationManager.shared.saveSoundEnabled(completed: sender.on)
        default:
            print("default")
        }
    }
}
