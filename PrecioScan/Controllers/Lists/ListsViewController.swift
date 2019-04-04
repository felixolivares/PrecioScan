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
import GoogleMobileAds


class ListsViewController: CustomTransitionViewController {

    
    @IBOutlet weak var mainListBannerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var mainListBannerView: GADBannerView!
    @IBOutlet weak var emptyStateContainerView: UIView!
    @IBOutlet weak var hamburgerButton: DynamicButton!
    @IBOutlet weak var tableView: UITableView!
    var lists:[List] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UserManager.shared.verifyUserIsLogged(vc: self)
        deselectCell()
        configureComponents()
        guard CoreDataManager.shared.getStack() == nil else {fetchLists(); return}
        CoreDataManager.shared.createStack{ finished in
            if finished{
                self.fetchLists()
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        hamburgerButton.setStyle(.hamburger, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Segues.toListDetailFromLists{
            let vc = segue.destination as! CreateListViewController
            vc.list = sender as? List
            vc.titleText = Constants.CreateList.listTitle
        } else if(segue.identifier == Segues.toNewListFromLists) {
            let vc = segue.destination as! CreateListViewController
            vc.titleText = Constants.CreateList.createListTItle
        } else if (segue.identifier == Segues.toSuscribeFromLists){
            let vc = segue.destination as! SubscriptionViewController
            vc.openedWithModal = true
        } else {
            let vc = segue.destination as! CreateListViewController
            vc.titleText = Constants.CreateList.createListTItle
        }
    }
    
    func configure() {
        setupTableView()
        CoreDataManager.shared.updateProducts()
        setupAds()
        setupRewardedAd()
    }
    
    //MARK: - Setup TableView
    func setupTableView(){
        let listCell = UINib(nibName: Identifiers.listTableViewCell, bundle: nil)
        tableView.register(listCell, forCellReuseIdentifier: CellIdentifiers.listCell)
        tableView.separatorStyle = .none
        //tableView.backgroundColor = UIColor.init(hexString: "F7F7F7")
        tableView.allowsSelection = true
        tableView.allowsMultipleSelectionDuringEditing = true
        tableView.rowHeight = UITableView.automaticDimension
    }
    
    func configureComponents(){
        hamburgerButton.setStyle(.hamburger, animated: false)
        adsViewabilty()
    }
    
    func setupAds(){
        mainListBannerView.adSize = kGADAdSizeBanner
        mainListBannerView.adUnitID = testingAds ? Constants.Admob.bannerTestId : Constants.Admob.bannerMainListId
        mainListBannerView.rootViewController = self
        mainListBannerView.delegate = self
        mainListBannerView.load(AdsManager.shared.getRequest())
    }
    
    func setupRewardedAd() {
        GADRewardBasedVideoAd.sharedInstance().delegate = self
        GADRewardBasedVideoAd.sharedInstance().load(GADRequest(), withAdUnitID: testingAds ? Constants.Admob.rewardedTestId : Constants.Admob.rewardedListsId)
    }
    
    func adsViewabilty(){
        if UserManager.shared.userIsSuscribed() {
            mainListBannerView.isHidden = true
            mainListBannerHeightConstraint.constant = 0
            self.view.layoutIfNeeded()
        }
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
                self.tableView.reloadData()
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
    
    func showRewardedAd() {
        if GADRewardBasedVideoAd.sharedInstance().isReady == true {
            GADRewardBasedVideoAd.sharedInstance().present(fromRootViewController: self)
        }
    }
    
    //MARK: - Buttons
    @IBAction func hamburgerButtonPressed(_ sender: Any) {
        hamburgerButton.setStyle(.close, animated: true)
        (self.navigationController as! NavigationListViewController).showSideMenu()
    }
    
    @IBAction func createNewListButtonPressed(_ sender: Any) {
        if lists.count >= 2 {
            SuscriptionManager.shared.promptToSubscribeWithRewarded(vc: self,
                                                        message: Constants.Lists.Popup.listRestriction,
                                                        completionHandler: { popupDecision, suscription in
                if suscription == SuscriptionManager.SubscriptionStatus.Subscribed{
                    self.performSegue(withIdentifier: Segues.toNewListFromLists, sender: nil)
                } else {
                    switch (popupDecision){
                    case PopupResponse.Buy:
                        self.performSegue(withIdentifier: Segues.toSuscribeFromLists, sender: nil)
                    case PopupResponse.ViewAd:
                        self.showRewardedAd()
                    default:
                        print("User is ok")
                    }
                }
            })
        } else {
            self.performSegue(withIdentifier: Segues.toNewListFromLists, sender: nil)
        }
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
        cell.sendSubviewToBack(cell.borderView)
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

//MARk: - Admob ads
extension ListsViewController: GADBannerViewDelegate{
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        bannerView.alpha = 0
        UIView.animate(withDuration: 0.3, animations: {
            bannerView.alpha = 1
        })
    }
}

extension ListsViewController: GADRewardBasedVideoAdDelegate {
    func rewardBasedVideoAd(_ rewardBasedVideoAd: GADRewardBasedVideoAd,
                            didRewardUserWith reward: GADAdReward) {
        print("Hellooo!! Reward received with currency: \(reward.type), amount \(reward.amount).")
        if (reward.type == Constants.Admob.RewardItem.list && reward.amount == 1) {
            self.performSegue(withIdentifier: Segues.toNewListFromLists, sender: nil)
        }
    }
    
    func rewardBasedVideoAdDidReceive(_ rewardBasedVideoAd:GADRewardBasedVideoAd) {
        print("Reward based video ad is received.")
    }
    
    func rewardBasedVideoAdDidOpen(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        print("Opened reward based video ad.")
    }
    
    func rewardBasedVideoAdDidStartPlaying(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        print("Reward based video ad started playing.")
    }
    
    func rewardBasedVideoAdDidCompletePlaying(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        print("Reward based video ad has completed.")
    }
    
    func rewardBasedVideoAdDidClose(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        print("Reward based video ad is closed.")
        self.setupRewardedAd()
    }
    
    func rewardBasedVideoAdWillLeaveApplication(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        print("Reward based video ad will leave application.")
    }
    
    func rewardBasedVideoAd(_ rewardBasedVideoAd: GADRewardBasedVideoAd,
                            didFailToLoadWithError error: Error) {
        print("Reward based video ad failed to load.")
    }
}
