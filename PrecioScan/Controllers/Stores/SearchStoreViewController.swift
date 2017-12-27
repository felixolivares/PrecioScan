//
//  SearchStoreViewController.swift
//  PrecioScan
//
//  Created by Félix Olivares on 28/11/17.
//  Copyright © 2017 Felix Olivares. All rights reserved.
//

import UIKit
import MKDropdownMenu

class SearchStoreViewController: UIViewController {

    @IBOutlet weak var storeNameTextField: UITextField!
    @IBOutlet weak var statesMenu: MKDropdownMenu!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noResultsContainerView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var addStoreButton: UIButton!
    
    var stateSelected: String!
    var dropDownIsOpen: Bool = false
    let componentTitles = States().allStates()
    var displayStateName = Constants.SearchStore.selectStateText
    var stateIsSelected: Bool = false
    let paragraphStyle = NSMutableParagraphStyle.init()
    var stores: [TempStore] = []
    var filteredStores: [TempStore] = []
    var storeSelected: Store!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if dropDownIsOpen{
            statesMenu.closeAllComponents(animated: false)
        }
        self.view.endEditing(true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        storeNameTextField.becomeFirstResponder()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        if (storeNameTextField.text?.count)! > 0{
            searchStore(name: storeNameTextField.text!, state: nil)
        }
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        goBack()
    }
    
    func configure(){
        configureMenu()
        configureTable()
        paragraphStyle.alignment = .left
        noResultsContainerView.alpha = 0
        activityIndicator.alpha = 0
//        addStoreButton.alpha = 0
        activityIndicator.hidesWhenStopped = true
    }
    
    func configureMenu(){
        statesMenu.dropdownShowsTopRowSeparator = true
        statesMenu.dropdownShowsBottomRowSeparator = false
        statesMenu.dropdownShowsBorder = true
        statesMenu.backgroundDimmingOpacity = 0
        statesMenu.componentTextAlignment = .left
    }
    
    func configureTable(){
        let storeTableViewCell = UINib(nibName: Identifiers.remoteStoreTableViewCell, bundle: nil)
        tableView.register(storeTableViewCell, forCellReuseIdentifier: CellIdentifiers.remoteStoreCell)
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor.white
        tableView.allowsSelection = true
        tableView.allowsMultipleSelectionDuringEditing = true
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    func searchStore(name: String? = nil, state: String? = nil){
        self.stores.removeAll()
        self.tableView.reloadData()
        self.hideNoResults()
        self.showActivityIndicator()
        FirebaseOperations().searchStores(withName: name?.lowercased().trimmingCharacters(in: .whitespacesAndNewlines), state: state?.lowercased()){ stores, error in
            if (stores?.count)! > 0{
                self.hideNoResults()
                self.hideActivityIndicator()
            }else{
                self.showNoResults()
            }
            self.stores = stores!
            self.filteredStores = stores!
            if self.stateIsSelected{
                self.setFilteredStores()
            }
            self.tableView.reloadData()
        }
    }
    
    func goBack(){
        if self.navigationController == nil {
            self.dismiss(animated: true, completion: nil)
        } else {
            if storeSelected == nil{
                navigationController?.popViewController(animated: true)
            } else {
                if navigationController is NavigationStoreViewController{
                    navigationController?.popViewController(animated: true)
                } else {
                    self.performSegue(withIdentifier: Segues.unwindToListFromSearch, sender: self)
                }
            }
        }
    }
    
    func showNoResults(){
        UIView.animate(withDuration: 0.3, animations: {
            self.noResultsContainerView.alpha = 1
//            self.addStoreButton.alpha = 1
        })
    }
    
    func hideNoResults(){
        UIView.animate(withDuration: 0.3, animations: {
            self.noResultsContainerView.alpha = 0
//            self.addStoreButton.alpha = 0
        })
    }
    
    func showActivityIndicator(){
        activityIndicator.startAnimating()
        UIView.animate(withDuration: 0.3, animations: {
            self.activityIndicator.alpha = 1
        })
    }
    
    func hideActivityIndicator(){
        UIView.animate(withDuration: 0.3, animations: {
            self.activityIndicator.alpha = 0
        })
        activityIndicator.stopAnimating()
    }
    
    func setFilteredStores(){
        if stateIsSelected{
            self.filteredStores = self.stores.filter{$0.state == self.stateSelected}
        } else {
           self.filteredStores = self.stores
        }
        self.tableView.reloadData()
        if self.filteredStores.count == 0{
            showNoResults()
        } else {
            hideNoResults()
        }
    }
    
    func saveStore(store: TempStore){
        CoreDataManager.shared.store(findByUid: store.uid){ stores, error in
            if (stores?.count)! > 0{
                Popup.show(withCompletionMessage: Constants.CreateStore.Popup.storeAlreadySaved, vc: self){ _ in
                    self.storeSelected = stores?.first
                    self.goBack()
                }
            } else {
                CoreDataManager.shared.saveStore(name: store.name, location: store.location, information: nil, state: store.state, city: store.city, needSaveFirbase: false, uid: store.uid){ store, error in
                    if let newStore = store {
                        self.storeSelected = newStore
                        Popup.show(withCompletionMessage: Constants.CreateStore.Popup.storeSaved, vc: self){ _ in
                            self.goBack()
                        }
                    }
                }

            }
        }
    }
}

//MARK: - MKDropdown Data Source
extension SearchStoreViewController: MKDropdownMenuDataSource{
    func numberOfComponents(in dropdownMenu: MKDropdownMenu) -> Int {
        return 1
    }
    
    func dropdownMenu(_ dropdownMenu: MKDropdownMenu, numberOfRowsInComponent component: Int) -> Int {
        return componentTitles.count
    }
}

//MARK: - MKDropdown Delegate Methods
extension SearchStoreViewController: MKDropdownMenuDelegate{
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
        let titleColor = self.stateIsSelected ? UIColor.black : UIColor(softGray)
        let titleFont = self.stateIsSelected ? UIFont(name: Font.ubuntuBoldFont, size: 17.0)! : UIFont(name: Font.ubuntuBoldFont, size: 14.0)!
        return NSMutableAttributedString(string: displayStateName, attributes: [NSAttributedStringKey.font: titleFont, NSAttributedStringKey.foregroundColor: titleColor!, NSAttributedStringKey.paragraphStyle: paragraphStyle])
        
    }
    
    func dropdownMenu(_ dropdownMenu: MKDropdownMenu, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        return NSAttributedString.init(string: componentTitles[row], attributes:[NSAttributedStringKey.font: UIFont(name: Font.ubuntuRegularFont, size: 17.0)!, NSAttributedStringKey.foregroundColor: UIColor.black, NSAttributedStringKey.paragraphStyle: paragraphStyle])
    }
    
    func dropdownMenu(_ dropdownMenu: MKDropdownMenu, didSelectRow row: Int, inComponent component: Int) {
        dropdownMenu.closeAllComponents(animated: true)
        self.displayStateName = componentTitles[row]
        self.stateSelected = componentTitles[row]
        //self.underlineState.backgroundColor = UIColor(spadeGreen)
        self.stateIsSelected  = componentTitles[row] != States.all ? true : false
        self.setFilteredStores()
        dropdownMenu.reloadAllComponents()
    }
    
    func dropdownMenu(_ dropdownMenu: MKDropdownMenu, didOpenComponent component: Int) {
        self.dropDownIsOpen = true
        self.view.endEditing(true)
        searchStore(name: storeNameTextField.text!, state: nil)
    }
    
    func dropdownMenu(_ dropdownMenu: MKDropdownMenu, didCloseComponent component: Int) {
        self.dropDownIsOpen = false
    }
    
    func dropdownMenu(_ dropdownMenu: MKDropdownMenu, backgroundColorForRow row: Int, forComponent component: Int) -> UIColor? {
        return UIColor(solitudeGray)
    }
}

extension SearchStoreViewController: UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.filteredStores.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.remoteStoreCell) as! RemoteStoreTableViewCell
        cell.storeName.text = filteredStores[indexPath.row].name + " - " + filteredStores[indexPath.row].location
        cell.locationLabel.text = filteredStores[indexPath.row].city + ", " + filteredStores[indexPath.row].state
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let store = filteredStores[indexPath.row]
        self.saveStore(store: store)
    }
}

extension SearchStoreViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchStore(name: storeNameTextField.text!, state: nil)
        self.view.endEditing(true)
        return false
    }
}
