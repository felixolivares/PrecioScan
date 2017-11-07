//
//  CreateStoreViewController.swift
//  PrecioScan
//
//  Created by Félix Olivares on 10/10/17.
//  Copyright © 2017 Felix Olivares. All rights reserved.
//

import UIKit
import PMSuperButton
import CoreData
import JSQCoreDataKit
import InteractiveSideMenu
import DynamicButton

protocol CreateStoreViewControllerDelegate{
    func storeSaved(store: Store)
}

class CreateStoreViewController: UIViewController, NSFetchedResultsControllerDelegate, SideMenuItemContent {

    @IBOutlet weak var storeNameAnimatedControl: AnimatedInputControl!
    @IBOutlet weak var locationNameAnimatedControl: AnimatedInputControl!
    @IBOutlet weak var saveButton: PMSuperButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var hamburgerButton: DynamicButton!
    @IBOutlet weak var backButton: UIButton!
    
    var fetchResultController: NSFetchedResultsController<Store>!
    var stores: [Store] = []
    var isComingFromList: Bool = false
    
    var delegate: CreateStoreViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchStores()
        configureComponents()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        hamburgerButton.setStyle(.hamburger, animated: true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    @IBAction func hamburgerButtonPressed(_ sender: Any) {
        hamburgerButton.setStyle(.close, animated: true)
        self.showSideMenu()
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        _ = navigationController?.popViewController(animated: true)
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        guard storeNameAnimatedControl.valueTextField.text != "", locationNameAnimatedControl.valueTextField.text != "" else{Popup.show(withOK: Warning.CreateStore.completeAllFieldsText, vc: self); return}
        CoreDataManager.shared.saveStore(name: storeNameAnimatedControl.valueTextField.text!, location: locationNameAnimatedControl.valueTextField.text!, information: nil){ storeSaved, error in
            if let store = storeSaved {
                self.tableView.reloadData()
                Popup.show(withCompletionMessage: Constants.CreateStore.Popup.storeSaved, vc: self){ _ in
                    self.delegate?.storeSaved(store: store)
                    _ = self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
    
    func configure(){
        hamburgerButton.isHidden = isComingFromList
        backButton.isHidden = !isComingFromList
        storeNameAnimatedControl.setDelegate()
        locationNameAnimatedControl.setDelegate()
        configureTable()
    }
    
    func configureTable(){
        let storeTableViewCell = UINib(nibName: Identifiers.storeTableViewCell, bundle: nil)
        tableView.register(storeTableViewCell, forCellReuseIdentifier: CellIdentifiers.storeCell)
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor.white
        tableView.allowsSelection = true
        tableView.allowsMultipleSelectionDuringEditing = true
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    func configureComponents(){
        hamburgerButton.setStyle(.hamburger, animated: false)
    }
    
    func fetchStores(){
        CoreDataManager.shared.stores{ _, stores, error in
            guard error == nil else {return}
            self.stores = stores!
            if self.stores.count > 0 {
                self.tableView.reloadData()
            }
        }
    }
    
    @objc func deleteButtonPressed(sender: UIButton){
        displayConfirmationPopup(index: sender.tag)
    }
    
    func displayConfirmationPopup(index: Int){
        Popup.showConfirmationNewArticle(title: Constants.CreateStore.Popup.attentionTitle,
                                         message: Constants.CreateStore.Popup.willDeleteStoreMessage,
                                         vc: self){ response in
                                            switch(response){
                                            case PopupResponse.Accept:
                                                self.deleteStore(index: index)
                                            case PopupResponse.Decline:
                                                print("")
                                            default:
                                                print("Nothing")
                                            }
        }
    }
    
    func deleteStore(index: Int){
        CoreDataManager.shared.deleteStore(object: stores[index]){ completed, error in
            if !completed{
                Popup.show(withError: error! as NSError, vc: self)
            }else{
                self.stores.remove(at: index)
                self.tableView.reloadData()
                print("Store deleted")
            }
        }
    }
}

extension CreateStoreViewController: UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stores.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.storeCell) as! StoreTableViewCell
        cell.storeNameLabel.text = stores[indexPath.row].name + " - " + stores[indexPath.row].location
        cell.deleteButton.tag = indexPath.row
        cell.deleteButton.addTarget(self, action: #selector(deleteButtonPressed(sender:)), for: .touchUpInside)
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0
    }
}

