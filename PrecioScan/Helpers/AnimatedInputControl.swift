//
//  AnimatedInputControl.swift
//  PrecioScan
//
//  Created by Félix Olivares on 07/10/17.
//  Copyright © 2017 Felix Olivares. All rights reserved.
//

import UIKit

class AnimatedInputControl: UIView {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var underline: UIView!
    @IBOutlet weak var nameLabelTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var valueTextField: UITextField!
    
    func setDelegate(){
        valueTextField.delegate = self
    }

    func animateFocus(){
        self.layoutIfNeeded()
        nameLabelTopConstraint.constant = 10
        UIView.animate(withDuration: 0.15) {
            self.layoutIfNeeded()
            self.underline.backgroundColor = UIColor(spadeGreen)
        }
    }
    
    func animateFocus(withCompletion handler: @escaping(Bool) -> Void){
        self.layoutIfNeeded()
        nameLabelTopConstraint.constant = 10
        UIView.animate(withDuration: 0.15, animations: {
            self.layoutIfNeeded()
            self.underline.backgroundColor = UIColor(spadeGreen)
        }) { (completed) in
            handler(true)
        }
    }
    
    func animateFocusOut(){
        nameLabelTopConstraint.constant = 38
        UIView.animate(withDuration: 0.15) {
            self.layoutIfNeeded()
            self.underline.backgroundColor = UIColor(softGreen)
        }
    }
    
    func setText(text: String?, animated: Bool?){
        if self.valueTextField.text == "" {
            animateFocus(withCompletion: { finished in
                self.valueTextField.alpha = 0
                self.valueTextField.text = text
                if animated != nil, animated == true{
                    UIView.animate(withDuration: 0.8, animations: {
                        self.valueTextField.alpha = 1
                    })
                }else{
                    self.valueTextField.alpha = 1
                }
            })
        }else{
            self.valueTextField.text = text
        }
    }
    
    func removeText(){
        self.valueTextField.text = ""
        animateFocusOut()
    }
}

extension AnimatedInputControl: UITextFieldDelegate{
    func textFieldDidBeginEditing(_ textField: UITextField) {
        (textField.superview as! AnimatedInputControl).animateFocus()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text?.count == 0{
            (textField.superview as! AnimatedInputControl).animateFocusOut()
        }
    }
}
