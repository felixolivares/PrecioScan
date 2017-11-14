//
//  RecoverPasswordViewController.swift
//  PrecioScan
//
//  Created by Félix Olivares on 10/11/17.
//  Copyright © 2017 Felix Olivares. All rights reserved.
//

import UIKit
import Firebase
import TransitionButton

class RecoverPasswordViewController: UIViewController {

    @IBOutlet weak var emailAnimatedControl: AnimatedInputControl!
    @IBOutlet weak var recoverButton: TransitionButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }

    func configure(){
        emailAnimatedControl.setDelegate()
        recoverButton.setLoading()
    }
    
    @IBAction func goBackButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func recoverButtonPressed(_ sender: Any) {
        recoverButton.startAnimation()
        let email = emailAnimatedControl.valueTextField.text
        guard email != "" else {
            Popup.show(withOK: Warning.RecoverPassword.emailMissing, title: Constants.Popup.Titles.attention, vc: self)
            recoverButton.stopAnimation()
            return
        }
        FirebaseOperations().sendPasswordReset(email: email!, button: recoverButton, vc: self)
    }
    
}
