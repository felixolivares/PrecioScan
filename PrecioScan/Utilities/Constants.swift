//
//  Constants.swift
//  PrecioScan
//
//  Created by Félix Olivares on 05/10/17.
//  Copyright © 2017 Felix Olivares. All rights reserved.
//

import Foundation

//Cell Identifiers
struct CellIdentifiers{
    public static let listCell = "ListCellIdentifier"
    public static let itemListCell = "ItemListTableViewCell"
}

//Font Names
struct Font {
    public static let ubuntuRegularFont = "Ubuntu-Regular"
    public static let ubuntuMediumFont = "Ubuntu-Medium"
    public static let ubuntuBoldFont = "Ubuntu-Bold"
}

//Text strings
struct Warning {
    struct CreateLlist {
        public static let selectNameAndStoreText = "Selecciona un nombre y una tienda antes"
    }
    
    struct CreateStore {
        public static let completeAllFieldsText = "Completa los campos para continuar"
    }
}

struct Constants {
    struct CreateList {
        public static let addStoreText = "Agregar tienda nueva..."
        public static let selectStoreText = "Seleccionar una tienda"
        public static let createListTItle = "Crear Lista"
        public static let listTitle = "Detalle de Lista"
    }
    
    struct AddArticle {
        public static let scanArticleCodeText = "Escabea el código de barras o introduce el código del artículo"
        public static let articleFoundText = "Articulo encontrado!"
        public static let articleNotFoundText = "Articulo no encontrado.\nSe creará un articulo nuevo."
        struct Popup {
            public static let addMoreArticlesMessage = "Deseas seguir agregando mas articulos?"
            public static let articleSavedTitle = "Articulo Guardado!"
        }
    }
    
    struct CreateStore{
        struct Popup {
            public static let storeSaved = "Tienda guardada!"
        }
    }
    
    struct Popup {
        public static let yesAnswer = "Si"
        public static let noAnswer = "No"
        public static let continueAnswer = "Continue"
    }
}

struct PopupResponse {
    public static let Accept = "PopupAccept"
    public static let Decline = "PopupDecline"
    public static let Continue = "PopupContinue"
}

//Identifiers
struct Identifiers {
    public static let notificationIdArticleFound = "NotificationIdArticleFound"
    public static let codeIdentifier = "code"
    public static let itemListTableViewCell = "ItemListTableViewCell"
    public static let listTableViewCell = "ListTableViewCell"
}

//Segues
struct Segues{
    public static let toStoresFromCreateList = "toStoresFromCreateList"
    public static let toArticleFromList = "toArticleFromList"
    public static let toListDetailFromLists = "toListDetailFromLists"
}
