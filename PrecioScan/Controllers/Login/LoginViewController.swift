//
//  LoginViewController.swift
//  PrecioScan
//
//  Created by Félix Olivares on 06/11/17.
//  Copyright © 2017 Felix Olivares. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var passwordAnimatedControl: AnimatedInputControl!
    @IBOutlet weak var emailAnimatedControl: AnimatedInputControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func configure(){
        passwordAnimatedControl.setDelegate()
        emailAnimatedControl.setDelegate()
    }
    
    @IBAction func loginButtonPressed(_ sender: Any) {
        guard emailAnimatedControl.valueTextField.text != "", passwordAnimatedControl.valueTextField.text != "" else {return}
        print("fields complete")
    }
    
    @IBAction func forgotPasswordButtonPressed(_ sender: Any) {
    }
    
    @IBAction func createAccountButtonPressed(_ sender: Any) {
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
