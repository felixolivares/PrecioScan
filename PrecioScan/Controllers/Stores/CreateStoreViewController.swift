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
import MKDropdownMenu
import GoogleMobileAds

protocol CreateStoreViewControllerDelegate{
    func storeSaved(store: Store)
}

class CreateStoreViewController: UIViewController, NSFetchedResultsControllerDelegate, UISearchBarDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var hamburgerButton: DynamicButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var searchBarContainer: UIView!
    @IBOutlet weak var emptyStateContainerView: UIView!
    @IBOutlet weak var bannerViewStoresList: GADBannerView!
    @IBOutlet weak var bannerViewStoresListHeightConstraint: NSLayoutConstraint!
    
    let searchController = UISearchController(searchResultsController: nil)
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
        configureComponents()
        fetchStores()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        searchController.searchBar.resignFirstResponder()
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
        (self.navigationController as! NavigationStoreViewController).showSideMenu()
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        _ = navigationController?.popViewController(animated: true)
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
    }
    
    //MARK: - Configure
    func configure(){
        hamburgerButton.isHidden = isComingFromList
        backButton.isHidden = !isComingFromList
        configureTable()
        configureSearchController()
        setupAds()
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
        UserManager.shared.verifyUserIsLogged(vc: self)
        hamburgerButton.setStyle(.hamburger, animated: false)
        emptyStateContainerView.isHidden = true
        adsViewabilty()
    }
    
    func configureSearchController(){
//        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = Constants.CreateStore.searchBarPlaceholder
        searchController.hidesNavigationBarDuringPresentation = false
        let searchBar = searchController.searchBar
        searchBar.searchBarStyle = .minimal
        searchBarContainer.addSubview(searchBar)
        definesPresentationContext = true
    }
    
    func setupAds(){
        bannerViewStoresList.adSize = kGADAdSizeBanner
        bannerViewStoresList.adUnitID = testingAds ? Constants.Admob.bannerTestId : Constants.Admob.bannerStoresListId
        bannerViewStoresList.rootViewController = self
        bannerViewStoresList.delegate = self
        bannerViewStoresList.load(AdsManager.shared.getRequest())
    }
    
    func adsViewabilty(){
        if UserManager.shared.userIsSuscribed() {
            bannerViewStoresList.isHidden = true
            bannerViewStoresListHeightConstraint.constant = 0
            self.view.layoutIfNeeded()
        }
    }
    
    func fetchStores(){
        CoreDataManager.shared.stores{ _, stores, error in
            guard error == nil else {return}
            self.stores = stores!
            if self.stores.count > 0 {
                self.emptyStateContainerView.isHidden = true
                self.tableView.reloadData()
            } else {
                self.emptyStateContainerView.isHidden = false
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
                self.fetchStores()
                self.tableView.reloadData()
                print("Store deleted")
            }
        }
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        self.performSegue(withIdentifier: Segues.toSearchFromStores, sender: nil)
        return false
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

//MARk: - Admob ads
extension CreateStoreViewController: GADBannerViewDelegate{
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        bannerView.alpha = 0
        UIView.animate(withDuration: 0.3, animations: {
            bannerView.alpha = 1
        })
    }
}

