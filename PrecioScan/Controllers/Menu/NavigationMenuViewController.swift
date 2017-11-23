//
//  NavigationMenuViewController.swift
//  PrecioScan
//
//  Created by Félix Olivares on 24/10/17.
//  Copyright © 2017 Felix Olivares. All rights reserved.
//

import UIKit
import InteractiveSideMenu

class NavigationMenuViewController: MenuViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userEmailLabel: UILabel!
    
    var currentUser: User!
    
    let menuItems = [Constants.NavigationMenu.listItem, Constants.NavigationMenu.storeItem, Constants.NavigationMenu.articleItem, Constants.NavigationMenu.configurationItem, Constants.NavigationMenu.logoutItem]
    let menuIcons = [ImageNames.listIcon, ImageNames.storeIcon, ImageNames.articleIcon, ImageNames.configurationIcon, ImageNames.logoutIcon]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        currentUser = CoreDataManager.shared.getUserLoggedIn()
        UserManager.setCurrentUser(user: currentUser)
        setUserInformation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Setup TableView
    func setupTableView(){
        let listCell = UINib(nibName: Identifiers.menuItemTableViewCell, bundle: nil)
        tableView.register(listCell, forCellReuseIdentifier: CellIdentifiers.menuItemCell)
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor.clear
        tableView.allowsSelection = true
        tableView.allowsMultipleSelectionDuringEditing = true
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    func setUserInformation(){
        userNameLabel.text = currentUser.name
        userEmailLabel.text = currentUser.email
    }
}

extension NavigationMenuViewController: UITableViewDataSource, UITableViewDelegate{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.menuItemCell) as! MenuItemTableViewCell
        cell.selectionStyle = .none
        cell.nameLabel.text = menuItems[indexPath.row]
        cell.iconImageView.image = UIImage(named: menuIcons[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let menuContainerViewController = self.menuContainerViewController else {
            return
        }
        if indexPath.row == menuContainerViewController.contentViewControllers.count{
            FirebaseOperations().signOut(vc: self){ success, error in
                if success{
                    menuContainerViewController.hideSideMenu()
                }else{
                    Popup.show(withError: error!, vc: self)
                }
            }
        } else {
            menuContainerViewController.selectContentViewController(menuContainerViewController.contentViewControllers[indexPath.row])
            menuContainerViewController.hideSideMenu()
        }
    }
}
