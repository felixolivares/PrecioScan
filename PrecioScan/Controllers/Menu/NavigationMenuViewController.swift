//
//  NavigationMenuViewController.swift
//  PrecioScan
//
//  Created by Félix Olivares on 24/10/17.
//  Copyright © 2017 Felix Olivares. All rights reserved.
//

import UIKit
import InteractiveSideMenu
import MessageUI
import FBSDKShareKit
import FBSDKCoreKit

class NavigationMenuViewController: MenuViewController, FBSDKAppInviteDialogDelegate {
    func appInviteDialog(_ appInviteDialog: FBSDKAppInviteDialog!, didCompleteWithResults results: [AnyHashable : Any]!) {
        print("")
    }
    
    func appInviteDialog(_ appInviteDialog: FBSDKAppInviteDialog!, didFailWithError error: Error!) {
        print("")
    }
    

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userEmailLabel: UILabel!
    @IBOutlet weak var heightPremiumIconConstraint: NSLayoutConstraint!
    
    var currentUser: User!
    
    var debugIsSubscribed: Bool = false
    
    let menuItems = [Constants.NavigationMenu.listItem, Constants.NavigationMenu.storeItem, Constants.NavigationMenu.articleItem, Constants.NavigationMenu.subscritpionIten, Constants.NavigationMenu.contactUsItem, Constants.NavigationMenu.configurationItem, Constants.NavigationMenu.logoutItem]
    let menuIcons = [ImageNames.listIcon, ImageNames.storeIcon, ImageNames.articleIcon, ImageNames.crwonIconWhite, ImageNames.contact1Icon, ImageNames.configurationIcon, ImageNames.logoutIcon]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //updateUserSubscribed(isSubscribed: debugIsSubscribed)
        currentUser = UserManager.shared.getCurrentUser()
        setUserInformation()
        loadProfilePhoto()
        if !UserManager.shared.userIsSuscribed(){
            heightPremiumIconConstraint.constant = 0
        } else {
            heightPremiumIconConstraint.constant = 21
        }
    }
    
    func updateUserSubscribed(isSubscribed: Bool){
        persistentContainer.updateUserSubscription(object: UserManager.shared.getCurrentUser()!, isSubscribed: isSubscribed, completionHandler: { finished, error in
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
    
    func sendEmail(){
        let composeVC = MFMailComposeViewController()
        composeVC.mailComposeDelegate = self
        
        // Configure the fields of the interface.
        composeVC.setToRecipients([Constants.Email.recipients])
        composeVC.setSubject(Constants.Email.subject)
        composeVC.setMessageBody(Constants.Email.messageBody, isHTML: false)
        
        // Present the view controller modally.
        self.present(composeVC, animated: true, completion: nil)
    }
    
    func facebookShare(){
        let whatsappURL:NSURL? = NSURL(string: "whatsapp://send?text=Hello%2C%20World!")
        if (UIApplication.shared.canOpenURL(whatsappURL! as URL)) {
            UIApplication.shared.openURL(whatsappURL! as URL)
        }
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
        return 53.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let menuContainerViewController = self.menuContainerViewController else {
            return
        }
        switch indexPath.row {
        case 4:
            self.sendEmail()
        case 5:
            menuContainerViewController.selectContentViewController(menuContainerViewController.contentViewControllers[4])
            menuContainerViewController.hideSideMenu()
        case 6:
            FirebaseOperations().signOut(vc: self){ success, error in
                if success{
                    menuContainerViewController.hideSideMenu()
                }else{
                    Popup.show(withError: error!, vc: self)
                }
            }
        default:
            menuContainerViewController.selectContentViewController(menuContainerViewController.contentViewControllers[indexPath.row])
            menuContainerViewController.hideSideMenu()
        }
    }
}

extension NavigationMenuViewController: MFMailComposeViewControllerDelegate{
    func mailComposeController(_ controller: MFMailComposeViewController,
                               didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
