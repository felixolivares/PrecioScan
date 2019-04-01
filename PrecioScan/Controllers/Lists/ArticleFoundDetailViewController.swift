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
    
    
    var articleSaved: Article!
    var itemListFound: ItemList!
    var store: Store!
    var list: List!
    var photoUid: String!
    var articleFound: Bool! = true
    var barcodeNotFound: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        popuplateFields()
        configure()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
    }

    @IBAction func backButtonPressed(_ sender: Any) {
        _ = navigationController?.popViewController(animated: true)
    }
    
    func configure() {
        stepper.addTarget(self, action: #selector(ArticleFoundDetailViewController.stepperValueChanged), for: .valueChanged)
        priceCurrencyTextField.addTarget(self, action: #selector(ArticleFoundDetailViewController.priceCurrencyChanged), for: .editingDidEnd)
        populateAnimatedControls()
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
    
    //MARK: - Buttons
    @IBAction func saveButtonPressed(_ sender: Any) {
        if priceCurrencyTextField.doubleValue > 0.0, nameAnimatedControl.valueTextField.text != "" {
            if articleFound {
                saveItemList()
            } else {
                CoreDataManager.shared.saveArticle(code: barcodeNotFound, name: nameAnimatedControl.valueTextField.text!){ article, error in
                    if article != nil {
                        self.articleSaved = article
                        self.saveItemList()
                    }else{
                        print("An error ocurred: \(String(describing: error?.localizedDescription))")
                    }
                }
            }
        } else {
            Popup.show(withOK: Warning.AddArticle.completePriceField, title: Constants.Popup.Titles.attention, vc: self)
        }
    }
    
    @IBAction func compareButtonPressed(_ sender: Any) {
        SuscriptionManager.shared.promptToSubscribe(vc: self, message: Constants.AddArticle.Popup.subscriptionRestriction, completionHandler: { popupDecision, suscription in
            if suscription == SuscriptionManager.SubscriptionStatus.Subscribed{
                if self.priceCurrencyTextField.doubleValue > 0.0 {
                    self.performSegue(withIdentifier: Segues.toCompareFromArticleFound, sender: nil)
                }else{
                    Popup.show(withOK: Warning.AddArticle.completeFieldsBeforeCompare, title: Constants.Popup.Titles.attention, vc: self)
                }
            } else {
                if popupDecision {
                    self.performSegue(withIdentifier: Segues.toSubscriptionFromArticleFound, sender: nil)
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
    
    func showUpdateMessage() {
        Popup.show(message: Constants.AddArticle.Popup.itemListUpdatedMessage, vc: self)
    }
    
    //MARK: - Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Segues.toCompareFromArticleFound {
            let vc = segue.destination as! CompareViewController
            vc.articleCode = itemListFound != nil ? itemListFound.article.code : articleSaved.code
            vc.store = store
            vc.todayPrice = itemListFound != nil ? CompareOperations().formatPrice(withDecimalNumber: itemListFound!.unitaryPrice) : self.priceCurrencyTextField.text
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
