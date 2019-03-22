//
//  SaveNewStoreViewController.swift
//  PrecioScan
//
//  Created by Félix Olivares on 27/11/17.
//  Copyright © 2017 Felix Olivares. All rights reserved.
//

import UIKit
import MKDropdownMenu

class SaveNewStoreViewController: UIViewController {

    @IBOutlet weak var storeNameAnimatedControl: AnimatedInputControl!
    @IBOutlet weak var locationNameAnimatedControl: AnimatedInputControl!
    @IBOutlet weak var cityNameAnimatedControl: AnimatedInputControl!
    @IBOutlet weak var statesMenu: MKDropdownMenu!
    @IBOutlet weak var underlineState: UIView!
    
    var stateSelected: String!
    var storeSelected: Store!
    var dropDownIsOpen: Bool = false
    let componentTitles = States().allStates()
    var displayStateName = Constants.CreateStore.selectStateText
    var stateIsSelected: Bool = false
    let paragraphStyle = NSMutableParagraphStyle.init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        confugure()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if dropDownIsOpen{
            statesMenu.closeAllComponents(animated: false)
        }
    }
    @IBAction func saveButtonPressed(_ sender: Any) {
        guard storeNameAnimatedControl.valueTextField.text != "", locationNameAnimatedControl.valueTextField.text != "", stateSelected != nil, cityNameAnimatedControl.valueTextField.text != "" else{Popup.show(withOK: Warning.CreateStore.completeAllFieldsText, title: Constants.Popup.Titles.attention, vc: self); return}
        CoreDataManager.shared.saveStore(name: storeNameAnimatedControl.valueTextField.text!, location: locationNameAnimatedControl.valueTextField.text!, information: nil, state: stateSelected, city: cityNameAnimatedControl.valueTextField.text!){ storeSaved, error in
            if let store = storeSaved {
                self.storeSelected = store 
                Popup.show(withCompletionMessage: Constants.CreateStore.Popup.storeSaved, vc: self){ _ in
                    //_ = self.navigationController?.popViewController(animated: true)
                    if self.navigationController != nil {
                        self.performSegue(withIdentifier: Segues.unwindToList, sender: self)
                    } else {
                        self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        if navigationController?.popViewController(animated: true)! == nil {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func confugure(){
        storeNameAnimatedControl.setDelegate()
        locationNameAnimatedControl.setDelegate(withPlaceholder: Constants.SaveNewStore.locationPlaceholder)
        cityNameAnimatedControl.setDelegate()
        configureMenu()
        paragraphStyle.alignment = .left
    }
    
    func configureMenu(){
        statesMenu.dropdownShowsTopRowSeparator = true
        statesMenu.dropdownShowsBottomRowSeparator = false
        statesMenu.dropdownShowsBorder = true
        statesMenu.backgroundDimmingOpacity = 0
        statesMenu.componentTextAlignment = .left
    }
}

//MARK: - MKDropdown Data Source
extension SaveNewStoreViewController: MKDropdownMenuDataSource{
    func numberOfComponents(in dropdownMenu: MKDropdownMenu) -> Int {
        return 1
    }
    
    func dropdownMenu(_ dropdownMenu: MKDropdownMenu, numberOfRowsInComponent component: Int) -> Int {
        return componentTitles.count
    }
}

//MARK: - MKDropdown Delegate Methods
extension SaveNewStoreViewController: MKDropdownMenuDelegate{
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
        let titleColor = self.stateIsSelected ? UIColor.black : UIColor(titleGray)
        let titleFont = self.stateIsSelected ? UIFont(name: Font.ubuntuBoldFont, size: 17.0)! : UIFont(name: Font.ubuntuMediumFont, size: 14.0)!
        return NSMutableAttributedString(string: displayStateName, attributes: [NSAttributedString.Key.font: titleFont, NSAttributedString.Key.foregroundColor: titleColor!, NSAttributedString.Key.paragraphStyle: paragraphStyle])
        
    }
    
    func dropdownMenu(_ dropdownMenu: MKDropdownMenu, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        return NSAttributedString.init(string: componentTitles[row], attributes:[NSAttributedString.Key.font: UIFont(name: Font.ubuntuRegularFont, size: 17.0)!, NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.paragraphStyle: paragraphStyle])
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
