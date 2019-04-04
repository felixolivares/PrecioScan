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
    
    //MARK: - Login
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
    
    //Mark: - Logout
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
    
    //MARK: - Create user
    public func createUser(email: String, password: String, username: String, state: String, city: String, button: TransitionButton, vc: UIViewController){
        self.networkActiviyIndicator(value: true)
        Auth.auth().createUser(withEmail: email, password: password){ user, error in
            if error == nil{
                Auth.auth().currentUser?.sendEmailVerification(){error in
                    if error == nil{
                        UserManager.shared.logIn(email: email)
                        self.updateUserLoggedIn(displayName: username, photoURL: nil, state: state, city: city)
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
                CoreDataManager.shared.saveUser(email: email, password: password, name: username, photoName: nil, state: state, city: city, isLogged: true, uid: Auth.auth().currentUser?.uid){ user, error in}
            } else {
                button.stopAnimation()
                Popup.show(withOK: Warning.Generic.genericError, title: Constants.Popup.Titles.attention, vc: vc)
            }
        }
    }
    
    //MARK: - Send password reset
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
    
    //MARK: - Update current user
    public func updateUserLoggedIn(displayName: String?, photoURL: String?, state: String?, city: String?){
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
                    self.addUser(state: state, city: city)
                }
                self.networkActiviyIndicator(value: false)
            }
        }
    }
    
    //MARK: - Save
    public func addUser(state: String?, city: String?){
        let user = Auth.auth().currentUser
        var values: [String: String?] = [:]
        if state != nil, city != nil {
            values = [FRAttribute.username: user?.displayName, FRAttribute.email: user?.email, FRAttribute.photoName: user?.photoURL?.absoluteString, FRAttribute.state: state!, FRAttribute.city: city!]
        } else {
            values = [FRAttribute.username: user?.displayName, FRAttribute.email: user?.email, FRAttribute.photoName: user?.photoURL?.absoluteString]
        }
        let userKey = self.ref.child(FRTable.user).child((user?.uid)!).key
        self.ref.child(FRTable.user).child(userKey!).updateChildValues((values as Any) as! [AnyHashable : Any])
    }
    
    public func updateCurrentUser(withSubscriptionDate date: Date, isSubscribed: Bool){
        let user = UserManager.shared.getCurrentUser()
        let values: [String: Any?] = [FRAttribute.username: user?.name, FRAttribute.email: user?.email, FRAttribute.photoName: user?.photoName, FRAttribute.isSubscribed: isSubscribed, FRAttribute.subscriptionDate: date.timeIntervalSince1970]
        self.ref.child(FRTable.user).child((user?.uid)!).setValue(values)
    }
    
    public func addArticle(barcode: String, name: String) -> String{
        let values: [String: String?] = [FRAttribute.code: barcode, FRAttribute.name: name]
        let articleRef = self.ref.child(FRTable.article).child(barcode)
        articleRef.setValue(values)
        return barcode
    }
    
    public func addStore(name: String, location: String, information: String?, state: String, city: String) -> String{
        let values: [String: String?] = [FRAttribute.name: name,
                                         FRAttribute.nameSearch: name.lowercased(),
                                         FRAttribute.location: location,
                                         FRAttribute.locationSearch: location.lowercased(),
                                         FRAttribute.information: information,
                                         FRAttribute.state: state,
                                         FRAttribute.stateSearch: state.lowercased(),
                                         FRAttribute.city: city,
                                         FRAttribute.citySearch: city.lowercased()]
        let storeRef = self.ref.child(FRTable.store).childByAutoId()
        storeRef.setValue(values)
        return storeRef.key!
    }
    
    public func addList(name: String, date: Date, storeId: String, userUid: String) -> String{
        let values: [String: Any?] = [FRAttribute.name: name,
                                      FRAttribute.date: date.timeIntervalSince1970,
                                      FRAttribute.store: [storeId: true],
                                      FRAttribute.user: userUid]
        let listRef = self.ref.child(FRTable.list).childByAutoId()
        listRef.setValue(values)
        return listRef.key!
    }
    
    public func addItemList(date: Date, photoName: String?, quantity: Int32, unitaryPrice: Decimal, articleUid: String, listUid: String, storeUid: String, userUid: String) -> String{
        var imageName: String = ""
        if photoName != nil{
            imageName = photoName!
        }
        let values: [String: Any?] = [FRAttribute.date: date.timeIntervalSince1970,
                                      FRAttribute.photoName: imageName,
                                      FRAttribute.quantity: String(describing: quantity),
                                      FRAttribute.unitaryPrice: String(describing: unitaryPrice),
                                      FRAttribute.article: [articleUid: true],
                                      FRAttribute.list: [listUid: true],
                                      FRAttribute.store: [storeUid: true],
                                      FRAttribute.user: [userUid: true]]
        
        let itemListRef = self.ref.child(FRTable.itemList).childByAutoId()
        itemListRef.setValue(values)
        
        self.ref.child(FRTable.list).child(listUid).child(FRAttribute.itemLists).queryOrdered(byChild: FRAttribute.itemLists).observeSingleEvent(of: .value, with: { snapshot in
            var itemLists: [String:Bool] = [:]
            if snapshot.exists(){
                if snapshot.childrenCount > 0{
                    for eachChild in snapshot.children{
                        itemLists[(eachChild as! DataSnapshot).key] = (eachChild as! DataSnapshot).value! as? Bool
                    }
                    itemLists[itemListRef.key!] = true
                    self.ref.child(FRTable.list).child(listUid).child(FRAttribute.itemLists).setValue(itemLists)
                }
            } else {
                itemLists[itemListRef.key!] = true
                self.ref.child(FRTable.list).child(listUid).child(FRAttribute.itemLists).setValue(itemLists)
            }
        })
        
        return itemListRef.key!
    }
    
    public func addPhotoToItemList(itemListUid: String, photoName: String? = nil){
        if photoName != nil{
            let values: [String: Any] = [FRAttribute.photoName: photoName!]
            self.ref.child(FRTable.itemList).child(itemListUid).updateChildValues(values)
        }
    }
    
    //MARK: - Search
    public func searchStores(withName name: String? = nil, state: String? = nil, completionHandler: @escaping([TempStore]?, NSError?) -> Void){
        self.ref.child(FRTable.store).queryOrdered(byChild: FRAttribute.nameSearch).queryStarting(atValue: name!).queryEnding(atValue: name! + "\u{f8ff}").observe(.value, with: {snapshot in
            var stores: [TempStore] = []
            for eachChild in snapshot.children{
                let store = ((eachChild as! DataSnapshot).value! as! [String:Any])
                let newStore = TempStore.init(name: store[FRAttribute.name] as! String, location: store[FRAttribute.location] as! String, state: store[FRAttribute.state] as! String, city: store[FRAttribute.city] as! String, uid: (eachChild as! DataSnapshot).key)
               stores.append(newStore)
            }
            completionHandler(stores, nil)
        })
    }
    
    public func searchCurrentUser(withId uid: String, completionHandler: @escaping(TempUser?) -> Void){
        self.ref.child(FRTable.user).child(uid).observe(.value, with:{ snapshot in
            if snapshot.exists(){
                var userDic = snapshot.value as! [String:Any]
                print("User dict: \(userDic)")
                let tmpUser = TempUser.init(email: userDic[FRAttribute.email] as! String,
                                            isSubscribed: userDic[FRAttribute.isSubscribed] as? Bool ?? false,
                                            uid: uid,
                                            subscriptionDate: userDic[FRAttribute.subscriptionDate] as? Double ?? nil,
                                            username: userDic[FRAttribute.username] as! String,
                                            state: userDic[FRAttribute.state] as! String,
                                            city: userDic[FRAttribute.city] as! String)
                print("Temp User: \(tmpUser)")
                completionHandler(tmpUser)
            } else {
                completionHandler(nil)
            }
        })
    }
    
    public func searchArticles(byCode code: String, completionHandler: @escaping(TempArticle?) -> Void){
        self.ref.child(FRTable.article).child(code).observeSingleEvent(of: .value, with: { snapshot in
            //var article: Article!
            if snapshot.exists(){
                if snapshot.childrenCount > 0{
                    print("[FirebaseOperations - searchArticles:byCode] Article found on Firebase")
                    let article = (snapshot.value! as! [String: Any])
                    let newArticle = TempArticle.init(code: article[FRAttribute.code] as! String, name: article[FRAttribute.name] as! String, uid: snapshot.key)
                    completionHandler(newArticle)
//                    for eachChild in snapshot.children{
//                        
//                    }
                }
            } else {
                completionHandler(nil)
            }
        })
    }
    
    //MARK: - Delete
    public func deleteList(byCode code: String){
        if code != "" {
            self.ref.child(FRTable.list).child(code).child(FRAttribute.itemLists).queryOrdered(byChild: FRAttribute.itemLists).observeSingleEvent(of: .value, with: { snapshot in
                if snapshot.exists(){
                    if snapshot.childrenCount > 0{
                        for eachChild in snapshot.children{
                            self.ref.child(FRTable.itemList).child((eachChild as! DataSnapshot).key).child(FRAttribute.list).removeValue()
                        }
                        self.ref.child(FRTable.list).child(code).removeValue()
                    }
                } else {
                    self.ref.child(FRTable.list).child(code).removeValue()
                }
            })
        }
    }
    
    public func deleteItemListFromList(byUid itemListUid: String, listUid: String){
        if itemListUid != ""{
            self.ref.child(FRTable.list).child(listUid).child(FRAttribute.itemLists).child(itemListUid).removeValue()
            self.ref.child(FRTable.itemList).child(itemListUid).child(FRAttribute.list).child(listUid).removeValue()
        }
    }
    
    private func networkActiviyIndicator(value: Bool){
        UIApplication.shared.isNetworkActivityIndicatorVisible = value
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
