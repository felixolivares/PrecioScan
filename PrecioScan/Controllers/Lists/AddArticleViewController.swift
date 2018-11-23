	//
//  AddArticleViewController.swift
//  PrecioScan
//
//  Created by Félix Olivares on 09/10/17.
//  Copyright © 2017 Felix Olivares. All rights reserved.
//

import UIKit
import GMStepper
import AVFoundation
import PMSuperButton
import ALCameraViewController
import AXPhotoViewer
import BadgeSwift
import FirebaseDatabase

class AddArticleViewController: UIViewController {

    @IBOutlet weak var barcodeLineScanner: BarcodeLine!
    @IBOutlet weak var barcodeReader: BarcodeReader!
    @IBOutlet weak var codeAnimatedControl: AnimatedInputControl!
    @IBOutlet weak var nameAnimatedControl: AnimatedInputControl!
    @IBOutlet weak var priceAnimatedControl: AnimatedInputControl!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var codeTextField: UITextField!
    @IBOutlet weak var stepper: GMStepper!
    @IBOutlet weak var compareButtonHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var messageCenterYConstraint: NSLayoutConstraint!
    @IBOutlet weak var compareButton: PMSuperButton!
    @IBOutlet weak var messageAndButtonContainerView: UIView!
    @IBOutlet weak var coinsIcon: UIImageView!
    @IBOutlet weak var photoBadge: BadgeSwift!
    
    var articles: [Article] = []
    var articleFound: Article!
    var store: Store!
    var list: List!
    var barcodeIsRead: Bool = false
    var articleIsFound: Bool = false
    var barcodeBeepPlayer: AVAudioPlayer?
    var itemListFound: ItemList!
    var photoExists: Bool = false
    var photosDataSource: [AXPhoto] = []
    var photosViewController: AXPhotosViewController!
    var isConnected: Bool = false
    var photoUid: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        barcodeLineScanner.startAnimation()
        barcodeReader.setupReader(codeAnimatedControl: codeAnimatedControl)
        if itemListFound != nil{
            populateWithItemListFound()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        barcodeLineScanner.layer.removeAllAnimations()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    //MARK: - Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Segues.toCompareFromArticle {
            let vc = segue.destination as! CompareViewController
            guard articleFound != nil else {return}
            vc.articleCode = articleFound.code
            vc.store = store
            vc.todayPrice = self.priceAnimatedControl.valueTextField.text
        } else if segue.identifier == Segues.toSubscriptionFromAddArticle{
            let vc = segue.destination as! SubscriptionViewController
            vc.openedWithModal = true
        }
    }
    
    //MARK: - Buttons
    @IBAction func backButtonPressed(_ sender: Any) {
        _ = navigationController?.popViewController(animated: true)
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        if articleIsFound{
            self.saveItemList()
        }else{
            if codeTextField.text != "", nameAnimatedControl.valueTextField.text != "", priceAnimatedControl.valueTextField.text != ""{
                CoreDataManager.shared.saveArticle(code: codeTextField.text!, name: nameAnimatedControl.valueTextField.text!){ article, error in
                    if article != nil {
                        self.articleFound = article
                        self.saveItemList()
                    }else{
                        print("An error ocurred: \(String(describing: error?.localizedDescription))")
                    }
                }
            }else{
                Popup.show(withOK: Warning.AddArticle.completeAllFieldsText, title: Constants.Popup.Titles.attention, vc: self)
            }
        }
        self.displayAddMoreArticlesPopup()
    }
    
    @IBAction func compareButtonPressed(_ sender: Any) {
        SuscriptionManager.shared.promptToSubscribe(vc: self, message: Constants.AddArticle.Popup.subscriptionRestriction, completionHandler: { popupDecision, suscription in
            if suscription == SuscriptionManager.SubscriptionStatus.Subscribed{
                if self.codeTextField.text != "", self.nameAnimatedControl.valueTextField.text != "", self.priceAnimatedControl.valueTextField.text != ""{
                    self.performSegue(withIdentifier: Segues.toCompareFromArticle, sender: nil)
                }else{
                    Popup.show(withOK: Warning.AddArticle.completeFieldsBeforeCompare, title: Constants.Popup.Titles.attention, vc: self)
                }
            } else {
                if popupDecision {
                    self.performSegue(withIdentifier: Segues.toSubscriptionFromAddArticle, sender: nil)
                }
            }
        })
    }
    
    @IBAction func photoButtonPressed(_ sender: Any) {
        SuscriptionManager.shared.promptToSubscribe(vc: self, message: Constants.AddArticle.Popup.photoSubscriptionRestriction, completionHandler: { popupDecision, suscription in
            if suscription == SuscriptionManager.SubscriptionStatus.Subscribed{
                if self.photoExists{
                    self.displayShowPhotoPopup()
                } else {
                    self.takePhoto()
                }
            } else {
                if popupDecision {
                    self.performSegue(withIdentifier: Segues.toSubscriptionFromAddArticle, sender: nil)
                }
            }
        })
    }
    
    //MARK: - Configure
    func configure(){
        nameAnimatedControl.setDelegate()
        priceAnimatedControl.setDelegate()
        NotificationCenter.default.addObserver(self, selector: #selector(self.receivedNotificationBarcodeFound(notification:)), name: Notification.Name(Identifiers.Notifications.idArticleFound), object: nil)
        compareButton.alpha = 0
        coinsIcon.alpha = 0
        photoBadge.alpha = 0
        createPhotoDataSource()
        UserManager.shared.verifyConnection(){ connected in
            self.isConnected = connected ? true : false
        }
    }
    
    //MARK: - Core Data
    func fetchArticles(withCode code: String?){
        guard barcodeIsRead == false else {return}
        if ConfigurationManager.soundEnabled! {
            self.playBarcodeSound()
        }
        codeAnimatedControl.setText(text: code, animated: true)
        CoreDataManager.shared.articles(findWithCode: code){ stack, articles, error in
            if let articles = articles{
                if articles.count > 0{
                    print("Local article")
                    self.articleWasFound(article: articles.first!)
                }else{
                    print("No local article")
                    FirebaseOperations().searchArticles(byCode: code!){article in
                        if article != nil{
                            CoreDataManager.shared.saveArticle(code: (article?.code)!, name: (article?.name)!, uid: (article?.uid)!, needsToSaveOnFirebase: false){ article, error in
                                if article != nil {
                                    self.articleWasFound(article: article!)
                                }else{
                                    print("An error ocurred: \(String(describing: error?.localizedDescription))")
                                }
                            }
                        } else {
                            print("No articles on server")
                            self.articleIsFound = false
                            self.articleFound = nil
                            self.messageLabel.text = Constants.AddArticle.articleNotFoundText
                            self.resetItemList()
                        }
                    }
                }
                self.messageLabel.bounce(){ finished in
                    guard self.articleFound != nil else {self.hideCompareButton();return}
                    CompareOperations().verifyMultipleItemListSaved(withObject: self.articleFound){ isFound in
                        if isFound{
                            self.showCompareButton()
                        }
                    }
                    self.setBadge()
                }
            }
            self.barcodeIsRead = true
        }
    }
    
    func articleWasFound(article: Article){
        self.articleIsFound = true
        self.articleFound = article
        self.messageLabel.text = Constants.AddArticle.articleFoundText
        self.populateWithArticleFound()
    }
    
    func showCompareButton(){
        self.messageCenterYConstraint.constant = -20
        UIView.animate(withDuration: 0.3, animations: {
            self.messageAndButtonContainerView.layoutIfNeeded()
        }, completion: { _ in
            UIView.animate(withDuration: 0.3, animations: {
                self.compareButton.alpha = 1.0
                self.coinsIcon.alpha = 1.0
            })
        })
    }
    
    func hideCompareButton(){
        UIView.animate(withDuration: 0.3, animations: {
            self.compareButton.alpha = 0
            self.coinsIcon.alpha = 0
        }, completion: { _ in
            self.messageCenterYConstraint.constant = 10
            UIView.animate(withDuration: 0.3, animations: {
                self.messageAndButtonContainerView.layoutIfNeeded()
            })
        })
    }
    
    func saveItemList(){
        
        let quantity = Int32(stepper.value)
        let unitaryPrice = Decimal(round(100*Double(priceAnimatedControl.valueTextField.text!)!)/100)
        guard itemListFound == nil else {
            CoreDataManager.shared.updateItemList(object: self.itemListFound, date: DateOperations().getCurrentLocalDate(),
                                                photoName: photoUid,
                                                quantity: quantity,
                                                unitariPrice: unitaryPrice,
                                                article: articleFound,
                                                list: list,
                                                store: store,
                                                user: UserManager.currentUser){ isSaved, itemListUpdated, error in
                                                    if isSaved {
                                                        self.itemListFound = itemListUpdated
                                                        print("Updated")
                                                    }
            }
            return
        }
        CoreDataManager.shared.saveItemList(date: DateOperations().getCurrentLocalDate(),
                                            photoName: photoUid,
                                            quantity: quantity,
                                            unitariPrice: unitaryPrice,
                                            article: articleFound,
                                            list: list,
                                            store: store){ itemListSaved, error in
            if itemListSaved != nil{
                itemListSaved?.debug()
            }
        }
    }
    
    func populateWithArticleFound(){
        nameAnimatedControl.setText(text: articleFound.name, animated: true)
    }
    
    func populateWithItemListFound(){
        nameAnimatedControl.setText(text: itemListFound.article.name, animated: true)
        codeAnimatedControl.setText(text: itemListFound.article.code, animated: true)
        priceAnimatedControl.setText(text: String(describing: itemListFound.unitaryPrice), animated: true)
        stepper.value = Double(itemListFound.quantity)
        fetchArticles(withCode: itemListFound.article.code)
    }
    
    func resetAll(){
        messageLabel.text = Constants.AddArticle.scanArticleCodeText
        codeAnimatedControl.removeText()
        nameAnimatedControl.removeText()
        priceAnimatedControl.removeText()
        stepper.value = 1
    }
    
    func resetItemList(){
        nameAnimatedControl.removeText()
        priceAnimatedControl.removeText()
        stepper.value = 1
    }
    
    @objc func receivedNotificationBarcodeFound(notification: Notification){
        if (notification.userInfo?[Identifiers.codeIdentifier] as? String) != nil {
            let barcode = notification.userInfo?[Identifiers.codeIdentifier] as! String
            if codeAnimatedControl.valueTextField.text != barcode{
                barcodeIsRead = false
                fetchArticles(withCode: barcode)
            }
        }
    }
    
    //MARK: - Popup
    func displayAddMoreArticlesPopup(){
        Popup.showConfirmationNewArticle(title: Constants.AddArticle.Popup.articleSavedTitle,
                                         message: Constants.AddArticle.Popup.addMoreArticlesMessage,
                                         vc: self){ response in
            switch(response){
            case PopupResponse.Accept:
                self.resetAll()
            case PopupResponse.Decline:
                _ = self.navigationController?.popViewController(animated: true)
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
    
    func playBarcodeSound(){
        DispatchQueue.global(qos: .background).async {
            if let sound = NSDataAsset(name: "BarcodeSound"){
                do {
                    self.barcodeBeepPlayer = try AVAudioPlayer(data: sound.data, fileTypeHint: AVFileType.mp3.rawValue)
                    self.barcodeBeepPlayer?.play()
                } catch {
                    // couldn't load file :(
                }
            }
        }
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
}
    
//MARK: - Textfield delegate methods
extension AddArticleViewController: UITextFieldDelegate{
    func textFieldDidBeginEditing(_ textField: UITextField) {
        (textField.superview as! AnimatedInputControl).animateFocus()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text?.count == 0{
            (textField.superview as! AnimatedInputControl).animateFocusOut()
        }else{
            print("End editing textfield")
            guard let codeValue = textField.text else {return}
            barcodeIsRead = false
            fetchArticles(withCode: codeValue)
        }
    }
}
