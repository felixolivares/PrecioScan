//
//  BarcodeReaderViewController.swift
//  PrecioScan
//
//  Created by Félix Olivares on 3/26/19.
//  Copyright © 2019 Felix Olivares. All rights reserved.
//

import UIKit
import SwiftySound

class BarcodeReaderViewController: UIViewController {

    @IBOutlet weak var barcodeReader: BarcodeReader!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    var articles: [Article] = []
    var articleFound: Article!
    var store: Store!
    var list: List!
    var barcodeRead: String!
    private var barcodeIsRead: Bool = false
    var articleIsFound: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        configure()
    }
    
    func configure() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.receivedNotificationBarcodeFound(notification:)), name: Notification.Name(Identifiers.Notifications.idArticleFound), object: nil)
        self.articleIsFound = true
        barcodeReader.setupReader()
    }
    
    @objc func receivedNotificationBarcodeFound(notification: Notification){
        if (notification.userInfo?[Identifiers.codeIdentifier] as? String) != nil {
            let barcode = notification.userInfo?[Identifiers.codeIdentifier] as! String
            barcodeIsRead = false
            fetchArticles(withCode: barcode)
            print("[BarcodeReader] - Barcode is: \(barcode)")
        }
    }
    
    //MARK: - Core Data
    func fetchArticles(withCode code: String?){
        NotificationCenter.default.removeObserver(self,
                                                  name: Notification.Name(Identifiers.Notifications.idArticleFound),
                                                  object: nil)
        activityIndicator.startAnimating()
        guard barcodeIsRead == false else {return}
        self.barcodeIsRead = true
        self.barcodeRead = code
        if ConfigurationManager.soundEnabled! {
            self.playBarcodeSound()
        }
        CoreDataManager.shared.articles(findWithCode: code){ stack, articles, error in
            if let articles = articles{
                if articles.count > 0{
                    print("[BarcodeReader] - Local article found, peform segue")
                    self.activityIndicator.stopAnimating()
                    self.articleFound = articles.first
                    self.performSegue(withIdentifier: Segues.toArticleDetailFromBarcodeReader, sender: articles.first)
                }else{
                    print("[BarcodeReader] - No local article found with code: \(String(describing: code))")
                    FirebaseOperations().searchArticles(byCode: code!){article in
                        if article != nil{
                            CoreDataManager.shared.saveArticle(code: (article?.code)!, name: (article?.name)!, uid: (article?.uid)!, needsToSaveOnFirebase: false){ article, error in
                                if article != nil {
                                    print("[BarcodeReader] - Article found in Firebase, perform segue")
                                    self.articleFound = article
                                    self.performSegue(withIdentifier: Segues.toArticleDetailFromBarcodeReader, sender: article)
                                    self.activityIndicator.stopAnimating()
                                }else{
                                    print("[BarcodeReader] - An error ocurred: \(String(describing: error?.localizedDescription))")
                                }
                            }
                        } else {
                            print("[BarcodeReader] - No articles on Firebase, will check external sources")
                            let barcode = self.prepareBarcode(code: code!)
                            print("[BarcodeReader] - Barcode prepared \(barcode)")
                            ClientManager.shared.getPath(sku: barcode){ response, error in
                                guard let articleName = response!.object(forKey: NetworkKeys.skuDisplayText) else {
                                    print("[BarcodReader] - No article found on exterlan sources")
                                    self.articleIsFound = false
                                    self.articleFound = nil
                                    self.performSegue(withIdentifier: Segues.toArticleDetailFromBarcodeReader, sender: nil)
                                    return
                                }
                                print("[BarcodeReader] - Article name: \(articleName)")
                                print("[BarcodeReader] - Remote response: \(String(describing: response))")
                                CoreDataManager.shared.saveArticle(code: code!, name: articleName as! String){ article, error in
                                    if article != nil {
                                        print("[BarcodeReader] - Article saved localy, perform segue")
                                        self.articleFound = article
                                        self.performSegue(withIdentifier: Segues.toArticleDetailFromBarcodeReader, sender: article)
                                        self.activityIndicator.stopAnimating()
                                    }else{
                                        print("[BarcodeReader] - An error ocurred: \(String(describing: error?.localizedDescription))")
                                    }
                                }
                            }
                        }
                    }
                }
            }
            self.barcodeIsRead = true
        }
    }
    
    
    //MARK: Button Actions
    
    @IBAction func backButtonPressed(_ sender: Any) {
        _ = navigationController?.popViewController(animated: true)
    }
    
    func playBarcodeSound(){
        DispatchQueue.global(qos: .background).async {
            Sound.play(file: "BarcodeSound.mp3")
        }
    }
    
    //MARK: - Barcode actions
    func prepareBarcode(code: String) -> String {
        let barcode = code.dropLast()
        return "00" + String(barcode)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        activityIndicator.stopAnimating()
        if segue.identifier == Segues.toArticleDetailFromBarcodeReader {
            let vc = segue.destination as! ArticleFoundDetailViewController
            vc.articleSaved = articleFound != nil ? sender as? Article : nil
            vc.list = list
            vc.store = store
            if !articleIsFound {
                vc.articleFound = false
                vc.barcodeNotFound = self.barcodeRead
            }
            print("Article sent: \(String(describing: sender as? Article))")
        }
    }
}
