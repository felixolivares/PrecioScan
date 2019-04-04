//
//  ArticleFoundDetailViewController.swift
//  PrecioScan
//
//  Created by Félix Olivares on 3/27/19.
//  Copyright © 2019 Felix Olivares. All rights reserved.
//

import UIKit
import GMStepper
import PMSuperButton
import GoogleMobileAds
import ALCameraViewController
import AXPhotoViewer
import BadgeSwift

class ArticleFoundDetailViewController: UIViewController {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var barcodeLabel: UILabel!
    @IBOutlet weak var articleImageView: UIImageView!
    @IBOutlet weak var priceCurrencyTextField: CurrencyTextField!
    @IBOutlet weak var totalPriceLabel: UILabel!
    @IBOutlet weak var stepper: GMStepper!
    @IBOutlet weak var saveButton: RoundedButton!
    @IBOutlet weak var compareButton: PMSuperButton!
    @IBOutlet weak var nameAnimatedControl: AnimatedInputControl!
    @IBOutlet weak var photoBadge: BadgeSwift!
    
    
    var articleSaved: Article!
    var itemListFound: ItemList!
    var store: Store!
    var list: List!
    var photoUid: String!
    var articleFound: Bool! = true
    var barcodeNotFound: String!
    var photoExists: Bool = false
    var photosDataSource: [AXPhoto] = []
    var photosViewController: AXPhotosViewController!
    var rewardedCompare: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        popuplateFields()
        configure()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
    }
    
    //MARK: - Configure
    func configure() {
        stepper.addTarget(self, action: #selector(ArticleFoundDetailViewController.stepperValueChanged), for: .valueChanged)
        priceCurrencyTextField.addTarget(self, action: #selector(ArticleFoundDetailViewController.priceCurrencyChanged), for: .editingDidEnd)
        populateAnimatedControls()
        setupRewardedAd()
        photoBadge.alpha = 0
        createPhotoDataSource()
        self.setBadge()
    }
    
    func popuplateFields() {
        guard articleFound else {
            barcodeLabel.text = barcodeNotFound
            self.articleImageView.image = #imageLiteral(resourceName: "PrecioScanLogo")
            return
        }
        if articleFound {
            nameLabel.text = itemListFound != nil ? itemListFound.article.name : articleSaved.name
            barcodeLabel.text = itemListFound != nil ? itemListFound.article.code : articleSaved.code
        } else {
            
        }
        
        //View/Update only
        if itemListFound != nil {
            priceCurrencyTextField.text = CompareOperations().formatPrice(withDecimalNumber: itemListFound.unitaryPrice)
            populateTotalPriceText(value: Double(truncating: itemListFound!.unitaryPrice), quantity: Double(itemListFound.quantity))
            stepper.value = Double(itemListFound.quantity)
            
            //Disable editables
            saveButton.setTitle("Actualizar", for: .normal)
        }
        
        //Image load
        ClientManager.shared.getImage(sku: prepareBarcode(code: itemListFound != nil ? itemListFound.article.code : articleSaved.code)) { image, error in
            if let image = image {
                self.articleImageView.image = image
            } else {
                self.articleImageView.image = #imageLiteral(resourceName: "PrecioScanLogo")
            }
        }
        
        //Compare button
        CompareOperations().verifyMultipleItemListSaved(withObject: itemListFound != nil ? itemListFound.article : self.articleSaved){ isFound in
            if isFound{
                self.compareButton.isHidden = false
            } else {
                self.compareButton.isHidden = true
            }
        }
    }
    
    func populateAnimatedControls(){
        if !articleFound {
            nameLabel.isHidden = true
            nameAnimatedControl.isHidden = false
        } else {
            nameLabel.isHidden = false
            nameAnimatedControl.isHidden = true
        }
    }

    func saveItemList(){
        let quantity = Int32(stepper.value)
        let unitaryPrice = priceCurrencyTextField.doubleValue
        guard itemListFound == nil else {
            CoreDataManager.shared.updateItemList(object: self.itemListFound, date: DateOperations().getCurrentLocalDate(),
                                                  photoName: photoUid,
                                                  quantity: quantity,
                                                  unitariPrice: Decimal(unitaryPrice),
                                                  article: articleSaved,
                                                  list: list,
                                                  store: store,
                                                  user: UserManager.currentUser){ isSaved, itemListUpdated, error in
                                                    if isSaved {
                                                        self.showUpdateMessage()
                                                        self.itemListFound = itemListUpdated
                                                        print("Updated")
                                                    }
            }
            return
        }
        CoreDataManager.shared.saveItemList(date: DateOperations().getCurrentLocalDate(),
                                            photoName: photoUid,
                                            quantity: quantity,
                                            unitariPrice: Decimal(unitaryPrice),
                                            article: articleSaved,
                                            list: list,
                                            store: store){ itemListSaved, error in
                                                if itemListSaved != nil{
                                                    itemListSaved?.debug()
                                                }
                                                self.displayAddMoreArticlesPopup()
        }
    }
    
    @objc func stepperValueChanged(stepper: GMStepper) {
        populateTotalPriceText(value: priceCurrencyTextField.doubleValue, quantity: stepper.value)
    }
    
    @objc func priceCurrencyChanged(priceTextField: CurrencyTextField) {
        let quantity = Int32(stepper.value)
        let totalPrice = Double(quantity) * priceTextField.doubleValue
        totalPriceLabel.text = "Total: \(String(describing: Formatter.currency.string(for: totalPrice)!))"
    }
    
    func prepareBarcode(code: String) -> String {
        let barcode = code.dropLast()
        return "00" + String(barcode)
    }
    
    func populateTotalPriceText(value: Double, quantity: Double){
        let totalPrice = Double(quantity) * value
        totalPriceLabel.text = "Total: \(String(describing: Formatter.currency.string(for: totalPrice)!))"
    }
    
    //MARK: - Ads
    func showRewarded() {
        if GADRewardBasedVideoAd.sharedInstance().isReady == true {
            GADRewardBasedVideoAd.sharedInstance().present(fromRootViewController: self)
        }
    }
    
    func setupRewardedAd() {
        GADRewardBasedVideoAd.sharedInstance().delegate = self
        GADRewardBasedVideoAd.sharedInstance().load(GADRequest(), withAdUnitID: testingAds ? Constants.Admob.rewardedTestId : Constants.Admob.rewardedArticleFound)
    }
    
    //MARK: - Buttons
    @IBAction func backButtonPressed(_ sender: Any) {
        _ = navigationController?.popViewController(animated: true)
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        if articleFound {
            if priceCurrencyTextField.doubleValue > 0.0 {
                saveItemList()
            } else {
                Popup.show(withOK: Warning.AddArticle.completePriceField, title: Constants.Popup.Titles.attention, vc: self)
            }
        } else {
            if nameAnimatedControl.valueTextField.text != "" {
                CoreDataManager.shared.saveArticle(code: barcodeNotFound, name: nameAnimatedControl.valueTextField.text!){ article, error in
                    if article != nil {
                        self.articleSaved = article
                        self.saveItemList()
                    }else{
                        print("An error ocurred: \(String(describing: error?.localizedDescription))")
                    }
                }
            } else {
                Popup.show(withOK: Warning.AddArticle.completeAllFieldsText, title: Constants.Popup.Titles.attention, vc: self)
            }
        }
        if nameAnimatedControl.valueTextField.text != "" {
            
        } else {
            Popup.show(withOK: Warning.AddArticle.completePriceField, title: Constants.Popup.Titles.attention, vc: self)
        }
    }
    
    @IBAction func compareButtonPressed(_ sender: Any) {
        rewardedCompare = true
        SuscriptionManager.shared.promptToSubscribeWithRewarded(vc: self, message: Constants.AddArticle.Popup.subscriptionRestriction, completionHandler: { popupDecision, suscription in
            if suscription == SuscriptionManager.SubscriptionStatus.Subscribed{
                if self.priceCurrencyTextField.doubleValue > 0.0 {
                    self.performSegue(withIdentifier: Segues.toCompareFromArticleFound, sender: nil)
                }else{
                    Popup.show(withOK: Warning.AddArticle.completeFieldsBeforeCompare, title: Constants.Popup.Titles.attention, vc: self)
                }
            } else {
                switch (popupDecision){
                case PopupResponse.Buy:
                    self.performSegue(withIdentifier: Segues.toSubscriptionFromArticleFound, sender: nil)
                case PopupResponse.ViewAd:
                    self.showRewarded()
                default:
                    print("User is ok")
                }
            }
        })
    }
    
    @IBAction func photoButtonPressed(_ sender: Any) {
        rewardedCompare = false
        SuscriptionManager.shared.promptToSubscribeWithRewarded(vc: self, message: Constants.AddArticle.Popup.photoSubscriptionRestriction, completionHandler: { popupDecision, suscription in
            if suscription == SuscriptionManager.SubscriptionStatus.Subscribed{
                if self.photoExists{
                    self.displayShowPhotoPopup()
                } else {
                    self.takePhoto()
                }
            } else {
                switch (popupDecision){
                case PopupResponse.Buy:
                    self.performSegue(withIdentifier: Segues.toSubscriptionFromArticleFound, sender: nil)
                case PopupResponse.ViewAd:
                    self.showRewarded()
                default:
                    print("User is ok")
                }
            }
        })
    }
    
    //MARK: - Popup
    func displayAddMoreArticlesPopup(){
        Popup.showConfirmationNewArticle(title: Constants.AddArticle.Popup.articleSavedTitle,
                                         message: Constants.AddArticle.Popup.addMoreArticlesMessage,
                                         vc: self){ response in
                                            switch(response){
                                            case PopupResponse.Accept:
                                                _ = self.navigationController?.popViewController(animated: true)
                                            case PopupResponse.Decline:
                                                self.performSegue(withIdentifier: Segues.unwindToCreateListFromArticleFound, sender: nil)
                                            default:
                                                print("Nothing")
                                            }
        }
    }
    
    func displayShowPhotoPopup(){
        Popup.showPhoto(title: Constants.AddArticle.Popup.photoAlreadySavedTitle,
                        message: Constants.AddArticle.Popup.photoAlreadySavedMessage,
                        vc: self){ response in
                            switch(response){
                            case PopupResponse.Show:
                                self.showPhoto()
                            case PopupResponse.Take:
                                self.takePhoto()
                            default:
                                print("Nothing")
                            }
        }
    }
    
    func showUpdateMessage() {
        Popup.show(message: Constants.AddArticle.Popup.itemListUpdatedMessage, vc: self)
    }
    
    //MARK: - Photo
    func showPhoto(){
        let dataSource = AXPhotosDataSource(photos: self.photosDataSource)
        photosViewController = AXPhotosViewController(dataSource: dataSource)
        
        let flex = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let bottomView = UIToolbar(frame: CGRect(origin: .zero, size: CGSize(width: 320, height: 44)))
        let customView = UILabel(frame: CGRect(origin: .zero, size: CGSize(width: 80, height: 20)))
        customView.text = "\(photosViewController.currentPhotoIndex + 1)"
        customView.textColor = .white
        customView.sizeToFit()
        bottomView.items = [
            flex,
            UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(AddArticleViewController.deletePhoto)),
        ]
        bottomView.backgroundColor = .clear
        bottomView.setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
        //photosViewController.overlayView.bottomStackContainer.insertSubview(bottomView, at: 0)
        self.present(photosViewController, animated: true)
    }
    
    @objc func deletePhoto(){
        if FilesManager.shared.deleteImage(imageName: itemListFound.photoName!){
            print("Photo deleted")
            photosViewController.dismiss(animated: true)
            
        } else {
            print("Photo not deleted")
        }
    }
    
    func createPhotoDataSource(){
        guard itemListFound != nil else {return}
        if let photoName = itemListFound.photoName{
            if let image = FilesManager.shared.verifyPhotoExists(name: photoName){
                print("Photo exists: \(String(describing: itemListFound.photoName!)).png")
                self.photoExists = true
                photosDataSource.append(AXPhoto(attributedTitle: NSAttributedString(string: itemListFound.article.name),
                                                attributedDescription: NSAttributedString(string: "$ " + String(describing: itemListFound.unitaryPrice)),
                                                attributedCredit: NSAttributedString(string: itemListFound.store.name),
                                                image: image))
            } else {
                print("Photo does not exist")
                self.photoExists = false
                CoreDataManager.shared.updateItemList(object: (self.itemListFound)!, date: nil,
                                                      photoName: "",
                                                      quantity: nil,
                                                      unitariPrice: nil,
                                                      article: nil,
                                                      list: nil,
                                                      store: nil,
                                                      user: nil){ isSaved, itemListUpdated, error in
                }
            }
        }
    }
    
    func takePhoto(){
        let cropParameters = CroppingParameters.init(isEnabled: true, allowResizing: true, allowMoving: true, minimumSize: CGSize(width: 60, height: 60))
        let cameraViewController = CameraViewController(croppingParameters: cropParameters, allowsLibraryAccess: true, allowsSwapCameraOrientation: true, allowVolumeButtonCapture: true) { [weak self] image, asset in
            guard image != nil else{self?.dismiss(animated: true, completion: nil); return}
            let uuid = UUID().uuidString
            print("Photo uuid generated: \(uuid)")
            if FilesManager.shared.saveImage(image: image!, photoName: uuid){
                print("Image saved")
                if self?.itemListFound != nil{
                    CoreDataManager.shared.updateItemList(object: (self?.itemListFound)!, date: nil,
                                                          photoName: uuid,
                                                          quantity: nil,
                                                          unitariPrice: nil,
                                                          article: nil,
                                                          list: nil,
                                                          store: nil,
                                                          user: nil){ isSaved, itemListUpdated, error in
                                                            if isSaved {
                                                                self?.itemListFound = itemListUpdated
                                                                print("Updated")
                                                                self?.photoExists = true
                                                                self?.setBadge()
                                                                self?.createPhotoDataSource()
                                                            }
                    }
                } else {
                    self?.photoUid = uuid
                }
            } else {
                print("Image not saved")
            }
            self?.dismiss(animated: true, completion: nil)
        }
        present(cameraViewController, animated: true, completion: nil)
    }
    
    func setBadge(){
        if photoExists{
            UIView.animate(withDuration: 0.5, animations: {
                self.photoBadge.alpha = 1
            })
        }
    }
    
    //MARK: - Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Segues.toCompareFromArticleFound {
            let vc = segue.destination as! CompareViewController
            vc.articleCode = itemListFound != nil ? itemListFound.article.code : articleSaved.code
            vc.store = store
            vc.todayPrice = itemListFound != nil ? CompareOperations().formatPrice(withDecimalNumber: itemListFound!.unitaryPrice) : self.priceCurrencyTextField.text
        } else {
            let vc = segue.destination as! SubscriptionViewController
            vc.openedWithModal = true
        }
    }
}

//MARK: - Textfield delegate methods
extension ArticleFoundDetailViewController: UITextFieldDelegate{
    func textFieldDidBeginEditing(_ textField: UITextField) {
        (textField.superview as! AnimatedInputControl).animateFocus()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text?.count == 0{
            (textField.superview as! AnimatedInputControl).animateFocusOut()
        }else{
            print("End editing textfield")
            guard textField.text != nil else {return}
        }
    }
}

extension ArticleFoundDetailViewController: GADRewardBasedVideoAdDelegate {
    
    func rewardBasedVideoAd(_ rewardBasedVideoAd: GADRewardBasedVideoAd,
                            didRewardUserWith reward: GADAdReward) {
        print("Reward received: \(reward.type), how many? \(reward.amount).")
        #if DEBUG
        if (reward.type == Constants.Admob.RewardItem.test && Int(truncating: reward.amount) >= 1) {
            if rewardedCompare {
                self.performSegue(withIdentifier: Segues.toCompareFromArticleFound, sender: nil)
            }
        }
        #else
        if (reward.type == Constants.Admob.RewardItem.article && Int(truncating: reward.amount) >= 1) {
            if rewardedCompare {
                self.performSegue(withIdentifier: Segues.toCompareFromArticleFound, sender: nil)
            }
        }
        #endif
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
        if !rewardedCompare {
            self.takePhoto()
        }
    }
    
    func rewardBasedVideoAdWillLeaveApplication(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        print("Reward based video ad will leave application.")
    }
    
    func rewardBasedVideoAd(_ rewardBasedVideoAd: GADRewardBasedVideoAd,
                            didFailToLoadWithError error: Error) {
        print("Reward based video ad failed to load.")
    }
}
