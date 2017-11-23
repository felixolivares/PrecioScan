//
//  Popup.swift
//  PrecioScan
//
//  Created by Félix Olivares on 12/10/17.
//  Copyright © 2017 Felix Olivares. All rights reserved.
//

import Foundation
import PopupDialog

class Popup{
    public static func setupPopup(){
        let cancelButtonAppearance = CancelButton.appearance()
        // Default button
        cancelButtonAppearance.titleFont        = UIFont.systemFont(ofSize: 14) //UIFont(name: "Nunito-Bold", size: 14)!
        cancelButtonAppearance.titleColor       = UIColor(nicePurple)
        cancelButtonAppearance.buttonColor      = UIColor.clear
        cancelButtonAppearance.separatorColor   = UIColor(nicePurple)?.withAlphaComponent(0.5)
        
        let defaultButtonAppereance = DefaultButton.appearance()
        defaultButtonAppereance.titleFont       = Fonts().ubuntuMedium(size: 14)
        defaultButtonAppereance.titleColor      = UIColor.white
        defaultButtonAppereance.buttonColor     = UIColor(oliveGreen)
        defaultButtonAppereance.separatorColor  = UIColor(oliveGreen)?.withAlphaComponent(0.5)
        
        let destructiveButtonAppereance = DestructiveButton.appearance()
        destructiveButtonAppereance.separatorColor = UIColor(oliveGreen)?.withAlphaComponent(0.5)
        
        let dialogAppearance = PopupDialogDefaultView.appearance()
        dialogAppearance.backgroundColor        = UIColor.white
        dialogAppearance.titleFont              = Fonts().ubuntuBold(size: 18)
        dialogAppearance.messageFont            = Fonts().ubuntuRegular(size: 16)
    }
    
    public static func show(withOK message:String?, title: String?, vc: UIViewController){
        let finalTitle: String!
        if title != nil{
            finalTitle = title!
        }else{
            finalTitle = ""
        }
        let popup = PopupDialog(title: finalTitle, message: message, buttonAlignment: .horizontal, transitionStyle: .zoomIn, gestureDismissal: true) {}
        let buttonOne = DefaultButton(title: "OK") {}
        popup.addButton(buttonOne)
        vc.present(popup, animated: true, completion: nil)
    }
    
    public static func show(message:String?, vc: UIViewController){
        let popup = PopupDialog(title: "", message: message, buttonAlignment: .horizontal, transitionStyle: .zoomIn, gestureDismissal: true) {}
        vc.present(popup, animated: true, completion: nil)
        let when = DispatchTime.now() + 2
        DispatchQueue.main.asyncAfter(deadline: when) {
            popup.dismiss()
        }
    }
    
    public static func show(OKWithCompletionAndMessage message: String?, title: String?, vc: UIViewController, completionHandler: @escaping (String) -> Void) {
        let finalTitle: String!
        if title != nil{
            finalTitle = title!
        }else{
            finalTitle = ""
        }
        let popup = PopupDialog(title: finalTitle, message: message, buttonAlignment: .horizontal, transitionStyle: .zoomIn, gestureDismissal: true) {}
        let buttonOne = DefaultButton(title: "OK") {
            popup.dismiss()
            completionHandler(Constants.Popup.Buttons.continueAnswer)
        }
        popup.addButton(buttonOne)
        vc.present(popup, animated: true, completion: nil)
    }
    
    public static func show(withCompletionMessage message: String?, vc: UIViewController, completionHandler: @escaping(String) -> Void){
        let popup = PopupDialog(title: "", message: message, buttonAlignment: .horizontal, transitionStyle: .zoomIn, gestureDismissal: true) {}
        vc.present(popup, animated: true, completion: nil)
        let when = DispatchTime.now() + 2
        DispatchQueue.main.asyncAfter(deadline: when) {
            popup.dismiss()
            completionHandler(Constants.Popup.Buttons.continueAnswer)
        }
    }
    
    public static func show(withError error: NSError, vc: UIViewController){
        let popup = PopupDialog(title: error.localizedFailureReason, message: error.localizedDescription, buttonAlignment: .horizontal, transitionStyle: .zoomIn, gestureDismissal: true) {}
        let buttonOne = DefaultButton(title: "OK") {}
        popup.addButton(buttonOne)
        vc.present(popup, animated: true, completion: nil)
    }
    
    public static func showConfirmationNewArticle(title: String?, message: String?, vc: UIViewController, completionHandler: @escaping(String) -> Void){
        let popup = PopupDialog(title: title, message: message, buttonAlignment: .horizontal, transitionStyle: .zoomIn, gestureDismissal: true) {}
        let buttonOK = DefaultButton(title: Constants.Popup.Buttons.yesAnswer){
            completionHandler(PopupResponse.Accept)
        }
        let buttonCancel = CancelButton(title: Constants.Popup.Buttons.noAnswer){
            completionHandler(PopupResponse.Decline)
        }
        popup.addButtons([buttonOK, buttonCancel])
        vc.present(popup, animated: true, completion: nil)
    }
    
    public static func showPhoto(title: String?, message: String?, vc: UIViewController, completionHandler: @escaping(String) -> Void){
        let popup = PopupDialog(title: title, message: message, buttonAlignment: .horizontal, transitionStyle: .zoomIn, gestureDismissal: true) {}
        let buttonOK = DefaultButton(title: Constants.Popup.Buttons.showPhoto){
            completionHandler(PopupResponse.Show)
        }
        let buttonCancel = CancelButton(title: Constants.Popup.Buttons.takePhoto){
            completionHandler(PopupResponse.Take)
        }
        popup.addButtons([buttonOK, buttonCancel])
        vc.present(popup, animated: true, completion: nil)
    }
}
