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
    
    var articles: [Article] = []
    var articleFound: Article!
    var store: Store!
    var list: List!
    var barcodeIsRead: Bool = false
    var articleIsFound: Bool = false
    var barcodeBeepPlayer: AVAudioPlayer?
    var itemListFound: ItemList!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        barcodeLineScanner.startAnimation()
        barcodeReader.setupReader(codeAnimatedControl: codeAnimatedControl)
        if itemListFound != nil{
            populateWithItemListFound()
        }
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
                Popup.show(withOK: Warning.AddArticle.completeAllFieldsText, vc: self)
            }
        }
        self.displayAddMoreArticlesPopup()
    }
    
    @IBAction func compareButtonPressed(_ sender: Any) {
        if codeTextField.text != "", nameAnimatedControl.valueTextField.text != "", priceAnimatedControl.valueTextField.text != ""{
            performSegue(withIdentifier: Segues.toCompareFromArticle, sender: nil)
        }else{
            Popup.show(withOK: Warning.AddArticle.completeFieldsBeforeCompare, vc: self)
        }
    }
    
    //MARK: - Configure
    func configure(){
        nameAnimatedControl.setDelegate()
        priceAnimatedControl.setDelegate()
        NotificationCenter.default.addObserver(self, selector: #selector(self.receivedNotificationBarcodeFound(notification:)), name: Notification.Name(Identifiers.notificationIdArticleFound), object: nil)
        compareButton.alpha = 0
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
                    self.articleIsFound = true
                    self.articleFound = articles.first
                    self.messageLabel.text = Constants.AddArticle.articleFoundText
                    self.populateWithArticleFound()
                }else{
                    self.articleIsFound = false
                    self.messageLabel.text = Constants.AddArticle.articleNotFoundText
                    self.resetItemList()
                }
                self.messageLabel.bounce(){ finished in
                    guard self.articleFound != nil else {return}
                    CompareOperations().verifyMultipleItemListSaved(withObject: self.articleFound){ isFound in
                        if isFound{
                            self.messageCenterYConstraint.constant = -20
                            UIView.animate(withDuration: 0.3, animations: {
                                self.messageAndButtonContainerView.layoutIfNeeded()
                            }, completion: { _ in
                                UIView.animate(withDuration: 0.3, animations: {
                                    self.compareButton.alpha = 1.0
                                })
                            })
                        }
                    }
                }
            }
            self.barcodeIsRead = true
        }
    }
    
    func saveItemList(){
        let quantity = Int32(stepper.value)
        let unitaryPrice = Decimal(round(100*Double(priceAnimatedControl.valueTextField.text!)!)/100)
        guard itemListFound == nil else {
            CoreDataManager.shared.updateItemList(object: self.itemListFound, date: DateOperations().getCurrentLocalDate(),
                                                photoName: nil,
                                                quantity: quantity,
                                                unitariPrice: unitaryPrice,
                                                article: articleFound,
                                                list: list,
                                                store: store){ isSaved, error in
                                                    if isSaved {
                                                        print("Updated")
                                                    }
            }
            return
        }
        CoreDataManager.shared.saveItemList(date: DateOperations().getCurrentLocalDate(),
                                            photoName: nil,
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
            let barcode = notification.userInfo?[Identifiers.codeIdentifier] as? String
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
