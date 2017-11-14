//
//  FirebaseOperations.swift
//  PrecioScan
//
//  Created by Félix Olivares on 10/11/17.
//  Copyright © 2017 Felix Olivares. All rights reserved.
//

import UIKit
import TransitionButton
import Firebase
import FirebaseDatabase

class FirebaseOperations: NSObject {

    var ref: DatabaseReference = Database.database().reference()
    
    //Login
    public func signIn(email: String, password: String, button: TransitionButton, vc: UIViewController){
        networkActiviyIndicator(value: true)
        Auth.auth().signIn(withEmail: email, password: password){ user, error in
            if error != nil{
                print("Sign in - Error code: \((error! as NSError).code) ")
                let customError = self.parseError(error: error! as NSError)
                Popup.show(withError: customError, vc: vc)
                button.stopAnimation()
            } else {
                button.stopAnimation(animationStyle: .expand, completion: {
                    UserManager.shared.logIn(email: email)
                    vc.dismiss(animated: false, completion: nil)
                })
            }
            self.networkActiviyIndicator(value: false)
        }
    }
    
    public func createUser(email: String, password: String, username: String, button: TransitionButton, vc: UIViewController){
        self.networkActiviyIndicator(value: true)
        Auth.auth().createUser(withEmail: email, password: password){ user, error in
            if error == nil{
                Auth.auth().currentUser?.sendEmailVerification(){error in
                    if error == nil{
                        UserManager.shared.logIn(email: email)
                        self.updateCurrentUser(displayName: username, photoURL: nil)
                        Popup.show(OKWithCompletionAndMessage: Warning.CreateAccount.usersaved, title: Constants.Popup.Titles.ready , vc: vc){ _ in
                            button.stopAnimation(animationStyle: .expand, completion: {
                                vc.presentingViewController?.presentingViewController?.dismiss(animated: false, completion: nil)
                            })
                        }
                    }else{
                        button.stopAnimation()
                        Popup.show(withOK: Warning.CreateAccount.verificationEmailError, title: Constants.Popup.Titles.attention, vc: vc)
                    }
                    self.networkActiviyIndicator(value: false)
                }
                CoreDataManager.shared.saveUser(email: email, password: password, name: username, photoName: nil, isLogged: true){ user, error in}
            } else {
                button.stopAnimation()
                Popup.show(withOK: Warning.Generic.genericError, title: Constants.Popup.Titles.attention, vc: vc)
            }
        }
    }
    
    public func sendPasswordReset(email: String, button: TransitionButton, vc: UIViewController){
        self.networkActiviyIndicator(value: true)
        Auth.auth().sendPasswordReset(withEmail: email){ error in
            if error != nil {
                let message: String!
                print("Error: \((error! as NSError).code)")
                switch (error! as NSError).code{
                case AuthErrorCode.userNotFound.rawValue, AuthErrorCode.invalidEmail.rawValue:
                    message = Constants.RecoverPassword.Messages.wrongEmail
                default:
                    message = Warning.Generic.genericError
                }
                Popup.show(withOK: message, title: Constants.Popup.Titles.attention, vc: vc)
                button.stopAnimation()
            }else{
                Popup.show(OKWithCompletionAndMessage: Warning.RecoverPassword.recoveryEmailSent, title: Constants.Popup.Titles.ready , vc: vc){ _ in
                    vc.dismiss(animated: true, completion: nil)
                }
            }
            self.networkActiviyIndicator(value: false)
        }
    }
    
    public func signOut(vc: UIViewController, completionHandler: @escaping(Bool, NSError?) -> Void){
        self.networkActiviyIndicator(value: true)
        UserManager.shared.logOut()
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            completionHandler(true, nil)
            self.networkActiviyIndicator(value: false)
        } catch let signOutError as NSError {
            completionHandler(false, signOutError)
            self.networkActiviyIndicator(value: false)
        }
    }
    
    public func updateCurrentUser(displayName: String?, photoURL: String?){
        self.networkActiviyIndicator(value: true)
        let user = Auth.auth().currentUser
        if let user = user {
            let changeRequest = user.createProfileChangeRequest()
            
            if let name = displayName{
                changeRequest.displayName = name
            }
            
            if let photo = photoURL{
                changeRequest.photoURL = URL(string: photo)
            }
            changeRequest.commitChanges { error in
                if error != nil {
                    print("Error: Profile not updated")
                } else {
                    print("Profile updated")
                    self.addUser()
                }
                self.networkActiviyIndicator(value: false)
            }
        }
    }
    
    private func networkActiviyIndicator(value: Bool){
        UIApplication.shared.isNetworkActivityIndicatorVisible = value
    }
    
    //Save
    
    public func addUser(){
        let user = Auth.auth().currentUser
        let values: [String: String?] = [FRAttribute.username: user?.displayName, FRAttribute.email: user?.email]
        self.ref.child(FRTable.user).child((user?.uid)!).setValue(values)
    }
    
    public func addArticle(barcode: String, name: String){
        let values: [String: String?] = [FRAttribute.name: name]
        self.ref.child(FRTable.article).child(barcode).setValue(values)
    }
    
    private func parseError(error: NSError) -> NSError{
        switch error.code{
        case AuthErrorCode.wrongPassword.rawValue:
            return NSError(type: ErrorType.wrongPassword)
        case AuthErrorCode.invalidEmail.rawValue:
            return NSError(type: ErrorType.invalidEmail)
        case AuthErrorCode.userNotFound.rawValue:
            return NSError(type: ErrorType.userNotFound)
        case AuthErrorCode.networkError.rawValue:
            return NSError(type: ErrorType.networkError)
        default:
            return NSError(type: ErrorType.genericError)
        }
    }
}
