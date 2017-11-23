//
//  CreateListViewController.swift
//  PrecioScan
//
//  Created by Félix Olivares on 05/10/17.
//  Copyright © 2017 Felix Olivares. All rights reserved.
//

import UIKit
import MKDropdownMenu
import CoreData
import JSQCoreDataKit
import PMSuperButton
import SwipeCellKit

class CreateListViewController: UIViewController, CreateStoreViewControllerDelegate {

    @IBOutlet weak var addStoreMenu: MKDropdownMenu!
    @IBOutlet weak var nameListAnimatedControl: AnimatedInputControl!
    @IBOutlet weak var addArticleButton: PMSuperButton!
    @IBOutlet weak var articlesContainer: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var underlineStore: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var totalArticlesLabel: UILabel!
    
    var componentTitles: [Store] = []
    let paragraphStyle = NSMutableParagraphStyle.init()
    var dropDownIsOpen: Bool = false
    var selectedStore: Store!
    var list: List!
    var itemLists: [ItemList] = []
    var displayStoreName = Constants.CreateList.selectStoreText
    
    var stack: CoreDataStack!
    var fetchResultController: NSFetchedResultsController<Store>!
    var stores: [Store] = []
    var titleText = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchStores()
        fetchItemLists()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if dropDownIsOpen{
            addStoreMenu.closeAllComponents(animated: false)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    //MARK: - Prepare for Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Segues.toArticleFromList{
            let vc = segue.destination as! AddArticleViewController
            vc.store = selectedStore
            vc.list = list
            if sender != nil{
                vc.itemListFound = sender as! ItemList
            }
        } else if segue.identifier == Segues.toStoresFromCreateList{
            let vc = segue.destination as! CreateStoreViewController
            vc.delegate = self
            vc.isComingFromList = true
        }
        
    }
    
    func configure(){
        configureMenu()
        configureComponents()
        configureTable()
        nameListAnimatedControl.setDelegate()
    }
    
    func configureMenu(){
        addStoreMenu.dropdownShowsTopRowSeparator = true
        addStoreMenu.dropdownShowsBottomRowSeparator = false
        addStoreMenu.dropdownShowsBorder = true
        addStoreMenu.backgroundDimmingOpacity = 0
        addStoreMenu.componentTextAlignment = .left
    }
    
    func configureComponents(){
        paragraphStyle.alignment = .left
        titleLabel.text = titleText
    }
    
    func configureTable(){
        let itemListTableViewCell = UINib(nibName: Identifiers.itemListTableViewCell, bundle: nil)
        tableView.register(itemListTableViewCell, forCellReuseIdentifier: CellIdentifiers.itemListCell)
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor.white
        
        tableView.allowsSelection = true
        tableView.allowsMultipleSelectionDuringEditing = true
        
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    func fetchStores(){
        CoreDataManager.shared.stores{stack, stores, error in
            guard error == nil else {return}
            self.stack = stack
            self.stores = stores!
            self.componentTitles.removeAll()
            if self.stores.count > 0 {
                for eachStore in self.stores{
                    self.componentTitles.append(eachStore)
                }
                self.addStoreMenu.reloadAllComponents()
            }
        }
    }
    
    func fetchItemLists(){
        if list != nil{
            self.populateFields()
            CoreDataManager.shared.itemLists(withList: list){ _, itemLists, error in
                guard error == nil else {Popup.show(withError: error!, vc: self); return}
                guard itemLists != nil else {self.itemLists = []; return}
                self.itemLists = itemLists!
                var grandTotal = Double()
                for eachItem in itemLists!{
                    grandTotal += eachItem.totalPrice as! Double
                }
                self.totalLabel.text = "$ " + String(grandTotal)
                self.totalArticlesLabel.text = "\(String(describing: (itemLists?.count)!))"
            }
        }
        tableView.reloadData()
    }
    
    func populateFields(){
        nameListAnimatedControl.setText(text: list.name, animated: false)
        if let storeRetrieved = list.store{
            storeSaved(store: storeRetrieved)
        }
    }
    
    //MARK: - Buttons pressed
    @IBAction func backButtonPressed(_ sender: Any) {
        _ = navigationController?.popViewController(animated: true)
    }
    
    @IBAction func addArticleButtonPressed(_ sender: Any) {
        guard selectedStore != nil, nameListAnimatedControl.valueTextField.text != "" else {Popup.show(withOK: Warning.CreateLlist.selectNameAndStoreText, title: Constants.Popup.Titles.attention, vc: self); return}
        if list != nil{
            print("List already created")
            list.debug()
            self.performSegue(withIdentifier: Segues.toArticleFromList, sender: nil)
        }else{
            CoreDataManager.shared.saveList(name: nameListAnimatedControl.valueTextField.text!, date: DateOperations().getCurrentLocalDate(), store: selectedStore){ listSaved, error in
                self.list = listSaved
                print("New list created")
                listSaved?.debug()
                self.performSegue(withIdentifier: Segues.toArticleFromList, sender: nil)
            }
        }
    }
    
    func storeSaved(store: Store) {
        self.selectedStore = store
        self.displayStoreName = store.name + " - " + store.location
        self.addStoreMenu.reloadAllComponents()
    }
}

//MARK: - TableView Data Source
extension CreateListViewController: UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemLists.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.itemListCell) as! ItemListTableViewCell
        let itemList = itemLists[indexPath.row]
        cell.quantityLabel.text = String(describing: itemList.quantity)
        cell.nameLabel.text = itemList.article.name
        cell.unitaryPriceLabel.text = "$" + String(describing: itemList.unitaryPrice)
        cell.totalPrice.text = "$" + String(describing: itemList.totalPrice)
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 59.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: Segues.toArticleFromList, sender: itemLists[indexPath.row])
    }
}

//MARK: - Swipe Cell Delegate Methods
extension CreateListViewController: SwipeTableViewCellDelegate{
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        
        let deleteAction = SwipeAction(style: .destructive, title: "Borrar") { action, indexPath in
            CoreDataManager.shared.delete(object: self.itemLists[indexPath.row]){ success, error in
                if success{
                    self.itemLists.remove(at: indexPath.row)
                }else{
                    Popup.show(withError: error! as NSError, vc: self)
                }
            }
        }
        let cell = tableView.cellForRow(at: indexPath) as! ItemListTableViewCell
        cell.hideSwipe(animated: true)
        
        // customize the action appearance
        deleteAction.title = "Borrar"
//        deleteAction.image = UIImage(named: "trash-circle")
//        deleteAction.backgroundColor = UIColor.white
        return [deleteAction]
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeTableOptions {
        var options = SwipeTableOptions()
        options.expansionStyle = .destructiveAfterFill
        options.transitionStyle = SwipeTableOptions().transitionStyle
        options.backgroundColor = UIColor.white
        return options
    }
}

//MARK: - MKDropdown Data Source
extension CreateListViewController: MKDropdownMenuDataSource{
    func numberOfComponents(in dropdownMenu: MKDropdownMenu) -> Int {
        return 1
    }
    
    func dropdownMenu(_ dropdownMenu: MKDropdownMenu, numberOfRowsInComponent component: Int) -> Int {
        return componentTitles.count + 1
    }
}

//MARK: - MKDropdown Delegate Methods
extension CreateListViewController: MKDropdownMenuDelegate{
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
        return NSMutableAttributedString(string: displayStoreName, attributes: [NSAttributedStringKey.font: UIFont(name: Font.ubuntuMediumFont, size: 14.0)!, NSAttributedStringKey.foregroundColor: UIColor.white, NSAttributedStringKey.paragraphStyle: paragraphStyle])

    }
    
    func dropdownMenu(_ dropdownMenu: MKDropdownMenu, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        if row < componentTitles.count{
            return NSAttributedString.init(string: componentTitles[row].name + " - " + componentTitles[row].location, attributes:[NSAttributedStringKey.font: UIFont(name: Font.ubuntuRegularFont, size: 17.0)!, NSAttributedStringKey.foregroundColor: UIColor.black, NSAttributedStringKey.paragraphStyle: paragraphStyle])
        }else{
            return NSAttributedString.init(string: Constants.CreateList.addStoreText, attributes:[NSAttributedStringKey.font: UIFont(name: Font.ubuntuRegularFont, size: 17.0)!, NSAttributedStringKey.foregroundColor: UIColor.black, NSAttributedStringKey.paragraphStyle: paragraphStyle])
        }
    }
    
    func dropdownMenu(_ dropdownMenu: MKDropdownMenu, didSelectRow row: Int, inComponent component: Int) {
        dropdownMenu.closeAllComponents(animated: false)
        if row < componentTitles.count{
            selectedStore = componentTitles[row]
            displayStoreName = selectedStore.name + " - " + selectedStore.location
            self.underlineStore.backgroundColor = UIColor(spadeGreen)
            dropdownMenu.reloadAllComponents()
        }else{
            performSegue(withIdentifier: Segues.toStoresFromCreateList, sender: self)
        }
    }
    
    func dropdownMenu(_ dropdownMenu: MKDropdownMenu, didOpenComponent component: Int) {
        self.dropDownIsOpen = true
    }
    
    func dropdownMenu(_ dropdownMenu: MKDropdownMenu, didCloseComponent component: Int) {
        self.dropDownIsOpen = false
    }
    
    func dropdownMenu(_ dropdownMenu: MKDropdownMenu, backgroundColorForRow row: Int, forComponent component: Int) -> UIColor? {
        return UIColor(solitudeGray)
    }
}
