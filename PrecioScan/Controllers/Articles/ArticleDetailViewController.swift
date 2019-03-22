//
//  ArticleDetailViewController.swift
//  PrecioScan
//
//  Created by Félix Olivares on 02/11/17.
//  Copyright © 2017 Felix Olivares. All rights reserved.
//

import UIKit

class ArticleDetailViewController: UIViewController {

    @IBOutlet weak var codeLabel: UILabel!
    @IBOutlet weak var averagePriceAnimatedControl: AnimatedInputControl!
    @IBOutlet weak var articleNameAnimatedControl: AnimatedInputControl!
    var articleSelected: Article!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        populateWithArticleSelected()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Segues.toCompareFromArticleDetail{
            let vc = segue.destination as! CompareViewController
            guard articleSelected != nil else {return}
            vc.articleCode = articleSelected.code
        } else if segue.identifier == Segues.toSubscribeFromArticleDetail{
            let vc = segue.destination as! SubscriptionViewController
            vc.openedWithModal = true
        }
    }
    
    @IBAction func goBackButtonPressed(_ sender: Any) {
        _ = navigationController?.popViewController(animated: true)
    }
    
    @IBAction func compareButtonPressed(_ sender: Any) {
        SuscriptionManager.shared.promptToSubscribe(vc: self, message: Constants.ArticleDetail.Poppup.subscriptionRestriction, completionHandler: { popupDecision, suscription in
            if suscription == SuscriptionManager.SubscriptionStatus.Subscribed{
                self.performSegue(withIdentifier: Segues.toCompareFromArticleDetail, sender: nil)
            } else {
                if popupDecision {
                    self.performSegue(withIdentifier: Segues.toSubscribeFromArticleDetail, sender: nil)
                }
            }
        })
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        guard articleNameAnimatedControl.valueTextField.text != "" else{Popup.show(withOK: Warning.ArticleDetail.addName, title: nil, vc: self); return}
        CoreDataManager.shared.updateArticle(object: articleSelected, name: articleNameAnimatedControl.valueTextField.text!){ success, error in
            if success{
                Popup.show(withCompletionMessage: Constants.ArticleDetail.Poppup.articleUpdated, vc: self){ _ in}
            }
        }
    }
    
    func populateWithArticleSelected(){
        articleNameAnimatedControl.setText(text: articleSelected.name, animated: true)
        codeLabel.text = articleSelected.code
        CompareOperations().getArticleAveragePrice(withCode: articleSelected.code){ average in
            self.averagePriceAnimatedControl.setText(text: average, animated: true)
        }
    }
}
