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
    @IBOutlet weak var heightPremiumIconConstraint: NSLayoutConstraint!
    
    var currentUser: User!
    
    let menuItems = [Constants.NavigationMenu.listItem, Constants.NavigationMenu.storeItem, Constants.NavigationMenu.articleItem, Constants.NavigationMenu.subscritpionIten, Constants.NavigationMenu.configurationItem, Constants.NavigationMenu.logoutItem]
    let menuIcons = [ImageNames.listIcon, ImageNames.storeIcon, ImageNames.articleIcon, ImageNames.subscriptionIcon, ImageNames.configurationIcon, ImageNames.logoutIcon]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        currentUser = UserManager.shared.getCurrentUser()
        setUserInformation()
        updateUserSubscribed()
        loadProfilePhoto()
        
        if !UserManager.shared.userIsSuscribed(){
            heightPremiumIconConstraint.constant = 0
        } else {
            heightPremiumIconConstraint.constant = 21
        }
    }
    
    func updateUserSubscribed(){
        persistentContainer.updateUserSubscription(object: currentUser, isSubscribed: true, completionHandler: { finished, error in
            if finished {
                print("User updated")
            }
        })
    }
    
    func configure(){
        setupTableView()
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
        profileImageView.clipsToBounds = true
        profileImageView.layer.borderWidth = 3.0
        profileImageView.layer.borderColor = UIColor.white.cgColor
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
    
    func loadProfilePhoto(){
        guard let photoName = currentUser.photoName, let photo = FilesManager.shared.getProfileImage(photoName: photoName) else {self.profileImageView.image = UIImage(named: ImageNames.profilePlaceholder); return}
        self.profileImageView.image = photo
    }
    
    @IBAction func profileButtonPressed(_ sender: Any) {
        guard let menuContainerViewController = self.menuContainerViewController else {
            return
        }
        menuContainerViewController.selectContentViewController(menuContainerViewController.contentViewControllers.last!)
        menuContainerViewController.hideSideMenu()
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
        if indexPath.row == menuContainerViewController.contentViewControllers.count - 1{
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
