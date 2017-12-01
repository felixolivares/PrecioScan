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
    
    private var placeholderTxt: String?
    
    func setDelegate(withPlaceholder placeholderText: String? = nil){
        valueTextField.delegate = self
        if let placeholder = placeholderText{
            self.placeholderTxt = placeholder
        }
    }

    func animateFocus(){
        self.layoutIfNeeded()
        nameLabelTopConstraint.constant = 0
        UIView.animate(withDuration: 0.15, animations:{
            self.layoutIfNeeded()
            self.underline.backgroundColor = UIColor(spadeGreen)
        }, completion:{ (finished: Bool) in
            if let placeholderTxt = self.placeholderTxt{
                self.valueTextField.placeholder = placeholderTxt
            }
        })
    }
    
    func animateFocus(withCompletion handler: @escaping(Bool) -> Void){
        self.layoutIfNeeded()
        nameLabelTopConstraint.constant = 0
        UIView.animate(withDuration: 0.15, animations: {
            self.layoutIfNeeded()
            self.underline.backgroundColor = UIColor(spadeGreen)
        }) { (completed) in
            self.valueTextField.placeholder = ""
            handler(true)
        }
    }
    
    func animateFocusOut(){
        self.valueTextField.placeholder = ""
        nameLabelTopConstraint.constant = 24
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
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField.tag == 101 {
            let newCharacters = NSCharacterSet.init(charactersIn: string)
            let boolIsNumber = NSCharacterSet.decimalDigits.isSuperset(of: newCharacters as CharacterSet)
            if boolIsNumber == true {
                return true
            } else {
                if string == "." {
                    let countdots = textField.text!.components(separatedBy: ".").count - 1
                    if countdots == 0 {
                        return true
                    } else {
                        if countdots > 0 && string == "." {
                            return false
                        } else {
                            return true
                        }
                    }
                } else {
                    return false
                }
            }
        }else{
            return true
        }
    }
}
