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
import MKDropdownMenu

class CreateAccountViewController: UIViewController {

    @IBOutlet weak var verifyPasswordAnimatedControl: AnimatedInputControl!
    @IBOutlet weak var passwordAnimatedControl: AnimatedInputControl!
    @IBOutlet weak var emailAnimatedControl: AnimatedInputControl!
    @IBOutlet weak var usernameAnimatedControl: AnimatedInputControl!
    @IBOutlet weak var createAccountButton: TransitionButton!
    @IBOutlet weak var cityAnimatedControl: AnimatedInputControl!
    @IBOutlet weak var underlineState: UIView!
    @IBOutlet weak var statesMenu: MKDropdownMenu!
    
    var dropDownIsOpen: Bool = false
    let componentTitles = States().allStates()
    var displayStateName = Constants.CreateStore.selectStateText
    var stateIsSelected: Bool = false
    let paragraphStyle = NSMutableParagraphStyle.init()
    var stateSelected: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if dropDownIsOpen{
            statesMenu.closeAllComponents(animated: false)
        }
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func configure(){
        configureMenu()
        emailAnimatedControl.setDelegate()
        passwordAnimatedControl.setDelegate()
        verifyPasswordAnimatedControl.setDelegate()
        usernameAnimatedControl.setDelegate()
        cityAnimatedControl.setDelegate()
    }
    
    func configureMenu(){
        statesMenu.dropdownShowsTopRowSeparator = true
        statesMenu.dropdownShowsBottomRowSeparator = false
        statesMenu.dropdownShowsBorder = true
        statesMenu.backgroundDimmingOpacity = 0
        statesMenu.componentTextAlignment = .left
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
        
        guard finalEmail != "", username != "", self.stateSelected != "", cityAnimatedControl.valueTextField.text != "", password != "", verifyPassword != "" else {Popup.show(withOK: Warning.CreateAccount.allFieldsCompleted, title: Constants.Popup.Titles.attention, vc: self);createAccountButton.stopAnimation();return}
        guard let pass = password?.count, pass >= 8 else {Popup.show(withOK: Warning.CreateAccount.passwordGreaterLength, title: Constants.Popup.Titles.attention, vc: self);createAccountButton.stopAnimation();return}
        guard password == verifyPassword else {Popup.show(withOK: Warning.CreateAccount.passwordsNeedToMatch, title: Constants.Popup.Titles.attention, vc: self);createAccountButton.stopAnimation();return}
        self.view.endEditing(true)
        FirebaseOperations().createUser(email: finalEmail!, password: password!, username: username!, state: self.stateSelected, city: cityAnimatedControl.valueTextField.text!, button: createAccountButton, vc: self)
    }
}

//MARK: - MKDropdown Data Source
extension CreateAccountViewController: MKDropdownMenuDataSource{
    func numberOfComponents(in dropdownMenu: MKDropdownMenu) -> Int {
        return 1
    }
    
    func dropdownMenu(_ dropdownMenu: MKDropdownMenu, numberOfRowsInComponent component: Int) -> Int {
        return componentTitles.count
    }
}

//MARK: - MKDropdown Delegate Methods
extension CreateAccountViewController: MKDropdownMenuDelegate{
    func dropdownMenu(_ dropdownMenu: MKDropdownMenu, rowHeightForComponent component: Int) -> CGFloat {
        return 40
    }
    
    func dropdownMenu(_ dropdownMenu: MKDropdownMenu, widthForComponent component: Int) -> CGFloat {
        return 30
    }
    
    func dropdownMenu(_ dropdownMenu: MKDropdownMenu, shouldUseFullRowWidthForComponent component: Int) -> Bool {
        return false
    }
    
    func dropdownMenu(_ dropdownMenu: MKDropdownMenu, attributedTitleForComponent component: Int) -> NSAttributedString? {
        let titleColor = UIColor.white
        let titleFont = self.stateIsSelected ? UIFont(name: Font.ubuntuBoldFont, size: 17.0)! : UIFont(name: Font.ubuntuMediumFont, size: 14.0)!
        return NSMutableAttributedString(string: displayStateName, attributes: [NSAttributedStringKey.font: titleFont, NSAttributedStringKey.foregroundColor: titleColor, NSAttributedStringKey.paragraphStyle: paragraphStyle])
        
    }
    
    func dropdownMenu(_ dropdownMenu: MKDropdownMenu, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        return NSAttributedString.init(string: componentTitles[row], attributes:[NSAttributedStringKey.font: UIFont(name: Font.ubuntuRegularFont, size: 17.0)!, NSAttributedStringKey.foregroundColor: UIColor.black, NSAttributedStringKey.paragraphStyle: paragraphStyle])
    }
    
    func dropdownMenu(_ dropdownMenu: MKDropdownMenu, didSelectRow row: Int, inComponent component: Int) {
        dropdownMenu.closeAllComponents(animated: false)
        self.displayStateName = componentTitles[row]
        self.stateSelected = componentTitles[row]
        self.underlineState.backgroundColor = UIColor(spadeGreen)
        self.stateIsSelected = true
        dropdownMenu.reloadAllComponents()
    }
    
    func dropdownMenu(_ dropdownMenu: MKDropdownMenu, didOpenComponent component: Int) {
        self.dropDownIsOpen = true
        self.view.endEditing(true)
    }
    
    func dropdownMenu(_ dropdownMenu: MKDropdownMenu, didCloseComponent component: Int) {
        self.dropDownIsOpen = false
    }
    
    func dropdownMenu(_ dropdownMenu: MKDropdownMenu, backgroundColorForRow row: Int, forComponent component: Int) -> UIColor? {
        return UIColor(solitudeGray)
    }
}
