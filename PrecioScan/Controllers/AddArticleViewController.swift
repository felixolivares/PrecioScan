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

class AddArticleViewController: UIViewController {

    @IBOutlet weak var barcodeLineScanner: BarcodeLine!
    @IBOutlet weak var barcodeReader: BarcodeReader!
    @IBOutlet weak var codeAnimatedControl: AnimatedInputControl!
    @IBOutlet weak var nameAnimatedControl: AnimatedInputControl!
    @IBOutlet weak var priceAnimatedControl: AnimatedInputControl!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var codeTextField: UITextField!
    @IBOutlet weak var stepper: GMStepper!
    
    var articles: [Article] = []
    var articleFound: Article!
    var store: Store!
    var list: List!
    var barcodeIsRead: Bool = false
    var articleIsFound: Bool = false
    var barcodeBeepPlayer: AVAudioPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        barcodeLineScanner.startAnimation()
        barcodeReader.setupReader(codeAnimatedControl: codeAnimatedControl)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    //MARK: - Buttons
    @IBAction func backButtonPressed(_ sender: Any) {
        _ = navigationController?.popViewController(animated: true)
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        if articleIsFound{
            self.saveItemList()
        }else{
            if let code = codeTextField.text, let name = nameAnimatedControl.valueTextField.text{
                CoreDataManager.shared.saveArticle(code: code, name: name){ article, error in
                    if article != nil {
                        self.articleFound = article
                        self.saveItemList()
                    }else{
                        print("An error ocurred: \(String(describing: error?.localizedDescription))")
                    }
                }
            }
        }
        self.displayAddMoreArticlesPopup()
    }
    
    //MARK: - Configure
    func configure(){
        nameAnimatedControl.setDelegate()
        priceAnimatedControl.setDelegate()
        NotificationCenter.default.addObserver(self, selector: #selector(self.receivedNotificationBarcodeFound(notification:)), name: Notification.Name(Identifiers.notificationIdArticleFound), object: nil)

    }
    
    //MARK: - Core Data
    func fetchArticles(withCode code: String?){
        guard barcodeIsRead == false else {return}
        self.playBarcodeSound()
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
                self.messageLabel.bounce()
            }
            self.barcodeIsRead = true
        }
    }
    
    func saveItemList(){
        let quantity = Int32(stepper.value)
        let unitaryPrice = Decimal(round(100*Double(priceAnimatedControl.valueTextField.text!)!)/100)
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
