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
    
    var articleSaved: Article!
    var itemListFound: ItemList!
    var store: Store!
    var list: List!
    var photoUid: String!
    
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
    }
    
    func popuplateFields() {
        nameLabel.text = itemListFound != nil ? itemListFound.article.name : articleSaved.name
        barcodeLabel.text = itemListFound != nil ? itemListFound.article.code : articleSaved.code
        
        //View only
        if itemListFound != nil {
            priceCurrencyTextField.text = CompareOperations().formatPrice(withDecimalNumber: itemListFound.unitaryPrice)
            populateTotalPriceText(value: Double(truncating: itemListFound!.unitaryPrice), quantity: Double(itemListFound.quantity))
            stepper.value = Double(itemListFound.quantity)
            
            //Disable editables
            priceCurrencyTextField.isEnabled = false
            stepper.isEnabled = false
            saveButton.isHidden = true
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

    func saveItemList(){
        let quantity = Int32(stepper.value)
        let unitaryPrice = priceCurrencyTextField.doubleValue
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
        if priceCurrencyTextField.doubleValue > 0.0 {
            saveItemList()
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

