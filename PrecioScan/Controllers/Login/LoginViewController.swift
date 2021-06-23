//
//  LoginViewController.swift
//  PrecioScan
//
//  Created by Félix Olivares on 06/11/17.
//  Copyright © 2017 Felix Olivares. All rights reserved.
//

import UIKit
import Firebase
import TransitionButton


class LoginViewController: UIViewController {

    @IBOutlet weak var passwordAnimatedControl: AnimatedInputControl!
    @IBOutlet weak var emailAnimatedControl: AnimatedInputControl!
    @IBOutlet weak var loginButton: TransitionButton!
    
    var debugMode: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        if debugMode{
            fillFields()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func configure(){
        if #available(iOS 13.0, *) {
            self.isModalInPresentation = true
        } else {
            // Fallback on earlier versions
        }
        passwordAnimatedControl.setDelegate()
        emailAnimatedControl.setDelegate()
//        loginButton.setLoading()
    }
    
    func fillFields(){
        emailAnimatedControl.setText(text: "felixoe@gmail.com", animated: true)
        passwordAnimatedControl.setText(text: "Jofel312", animated: true)
    }
    
    
    @IBAction func loginButtonPressed(_ button: TransitionButton) {
        button.startAnimation()
        guard emailAnimatedControl.valueTextField.text != "", passwordAnimatedControl.valueTextField.text != "" else {
            button.stopAnimation(animationStyle: .shake, revertAfterDelay: 0.0, completion: {
                Popup.show(withOK: Warning.Login.completeFields, title: Constants.Popup.Titles.attention, vc: self);
            })
            return
        }
        FirebaseOperations().signIn(email: emailAnimatedControl.valueTextField.text!, password: passwordAnimatedControl.valueTextField.text!, button: button, vc: self)
    }
    
    @IBAction func forgotPasswordButtonPressed(_ sender: Any) {
    }
    
    @IBAction func createAccountButtonPressed(_ sender: Any) {
    }
}

func presentationControllerShouldDismiss(_ presentationController: UIPresentationController) -> Bool {
    return false
}
