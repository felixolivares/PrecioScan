//
//  CreateAccountViewController.swift
//  PrecioScan
//
//  Created by Félix Olivares on 07/11/17.
//  Copyright © 2017 Felix Olivares. All rights reserved.
//

import UIKit
import Firebase
import TransitionButton

class CreateAccountViewController: UIViewController {

    @IBOutlet weak var verifyPasswordAnimatedControl: AnimatedInputControl!
    @IBOutlet weak var passwordAnimatedControl: AnimatedInputControl!
    @IBOutlet weak var emailAnimatedControl: AnimatedInputControl!
    @IBOutlet weak var usernameAnimatedControl: AnimatedInputControl!
    @IBOutlet weak var createAccountButton: TransitionButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func configure(){
        emailAnimatedControl.setDelegate()
        passwordAnimatedControl.setDelegate()
        verifyPasswordAnimatedControl.setDelegate()
        usernameAnimatedControl.setDelegate()
    }
    
    @IBAction func goBackButtonPressed(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func createAccountButtonPressed(_ sender: Any) {
        
    }
    
    @IBAction func createAccountBtnPressed(_ sender: Any) {
        createAccountButton.startAnimation()
        let email = emailAnimatedControl.valueTextField.text
        let password = passwordAnimatedControl.valueTextField.text
        let verifyPassword = verifyPasswordAnimatedControl.valueTextField.text
        let username = usernameAnimatedControl.valueTextField.text
        let finalEmail = email?.trimmingCharacters(in: .whitespaces)
        
        guard finalEmail != "", username != "", password != "", verifyPassword != "" else {Popup.show(withOK: Warning.CreateAccount.allFieldsCompleted, title: Constants.Popup.Titles.attention, vc: self);return}
        guard let pass = password?.count, pass >= 8 else {Popup.show(withOK: Warning.CreateAccount.passwordGreaterLength, title: Constants.Popup.Titles.attention, vc: self); return}
        guard password == verifyPassword else {Popup.show(withOK: Warning.CreateAccount.passwordsNeedToMatch, title: Constants.Popup.Titles.attention, vc: self); return}
        self.view.endEditing(true)
        FirebaseOperations().createUser(email: finalEmail!, password: password!, username: username!, button: createAccountButton, vc: self)
    }
    
}
