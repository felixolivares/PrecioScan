//
//  ListsViewController.swift
//  PrecioScan
//
//  Created by Félix Olivares on 05/10/17.
//  Copyright © 2017 Felix Olivares. All rights reserved.
//

import UIKit
import DynamicButton
import InteractiveSideMenu
import TableViewReloadAnimation
import Firebase
import TransitionButton
import SwipeCellKit

class ListsViewController: CustomTransitionViewController {

    
    @IBOutlet weak var emptyStateContainerView: UIView!
    @IBOutlet weak var hamburgerButton: DynamicButton!
    @IBOutlet weak var tableView: UITableView!
    var lists:[List] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        CoreDataManager.shared.updateProducts()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UserManager.shared.verifyUserIsLogged(vc: self)
        deselectCell()
        guard CoreDataManager.shared.getStack() == nil else {fetchLists(); return}
        CoreDataManager.shared.createStack{ finished in
            if finished{
                self.fetchLists()
            }
        }
        configureComponents()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        hamburgerButton.setStyle(.hamburger, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Segues.toListDetailFromLists{
            let vc = segue.destination as! CreateListViewController
            vc.list = sender as! List
            vc.titleText = Constants.CreateList.listTitle
        }else{
            let vc = segue.destination as! CreateListViewController
            vc.titleText = Constants.CreateList.createListTItle
        }
    }
    
    //MARK: - Setup TableView
    func setupTableView(){
        let listCell = UINib(nibName: Identifiers.listTableViewCell, bundle: nil)
        tableView.register(listCell, forCellReuseIdentifier: CellIdentifiers.listCell)
        tableView.separatorStyle = .none
        //tableView.backgroundColor = UIColor.init(hexString: "F7F7F7")
        tableView.allowsSelection = true
        tableView.allowsMultipleSelectionDuringEditing = true
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    func configureComponents(){
        hamburgerButton.setStyle(.hamburger, animated: false)
    }
    
    func fetchLists(){
        CoreDataManager.shared.lists{ _, lists, error in
            guard error == nil else {Popup.show(withError: error! as NSError, vc: self);return}
            self.lists = lists!
            if self.lists.count > 0{
                self.emptyStateContainerView.isHidden = true
                print("Lists Fetched!")
                self.tableView.reloadData(
                    with: .simple(duration: 0.45, direction: .rotation3D(type: .ironMan),
                                  constantDelay: 0))
            } else {
                self.emptyStateContainerView.isHidden = false
            }
        }
    }
    
    func deselectCell(){
        if let index = self.tableView.indexPathForSelectedRow{
            let cell = self.tableView.cellForRow(at: index) as! ListTableViewCell
            cell.borderView.layer.borderColor = UIColor(softGray)?.cgColor
        }
    }
    
    //MARK: - Buttons
    @IBAction func hamburgerButtonPressed(_ sender: Any) {
        hamburgerButton.setStyle(.close, animated: true)
        (self.navigationController as! NavigationListViewController).showSideMenu()
    }
    
    @IBAction func createNewListButtonPressed(_ sender: Any) {
        
    }
    
}

extension ListsViewController: UITableViewDataSource, UITableViewDelegate{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lists.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.listCell) as! ListTableViewCell
        cell.delegate = self
        cell.selectionStyle = .none
        cell.listNameLabel.text = lists[indexPath.row].name
        if let store = lists[indexPath.row].store{
            cell.storeNameLabel.text = store.name + " - " + store.location
        }
        cell.dateLabel.text = DateOperations().dateForList(date: lists[indexPath.row].date as Date)
        cell.numberOfArticlesLabel.text = String(lists[indexPath.row].itemList.count)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 95.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! ListTableViewCell
//        cell.contentView.backgroundColor = UIColor.clear
        cell.borderView.layer.borderColor = UIColor(oliveGreen)?.cgColor
        cell.sendSubview(toBack: cell.borderView)
        self.performSegue(withIdentifier: Segues.toListDetailFromLists, sender: lists[indexPath.row])
    }
}

//MARK: - Swipe Cell Delegate Methods
extension ListsViewController: SwipeTableViewCellDelegate{
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        
        let deleteAction = SwipeAction(style: .destructive, title: "Borrar") { action, indexPath in
            CoreDataManager.shared.delete(object: self.lists[indexPath.row]){ success, error in
                if success{
                    self.lists.remove(at: indexPath.row)
                }else{
                    Popup.show(withError: error! as NSError, vc: self)
                }
            }
        }
        let cell = tableView.cellForRow(at: indexPath) as! ListTableViewCell
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
