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
    public static let itemListCell = "ItemListCellIdentifier"
    public static let menuItemCell = "MenuItemCellIdentifier"
    public static let compareCell = "CompareCellIdentifier"
    public static let storeCell = "StoreCellIdentifier"
    public static let articleCell = "ArticleCellIdentifier"
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
    
    struct AddArticle{
        public static let completeAllFieldsText = "Completa los campos para continuar"
        public static let completeFieldsBeforeCompare = "Debes de completar todos los campos antes de comparar"
    }
    
    struct ArticleDetail{
        public static let addName = "Debes ingresar un nombre para el articulo"
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
        public static let fromMenu = "ComeFromMenu"
        public static let fromList = "ComeFromList"
        struct Popup {
            public static let storeSaved = "Tienda guardada!"
            public static let attentionTitle = "Atención!"
            public static let willDeleteStoreMessage = "Al borrar esta tienda, tambien se borraran sus listas asociadas a ella, estas de acuerdo?"
        }
    }
    
    struct ArticleDetail {
        struct Poppup {
            public static let articleUpdated = "Articulo actualizado"
        }
    }
    
    struct Compare {
        public static let historyTitle = "Historial:"
    }
    
    struct Popup {
        public static let yesAnswer = "Si"
        public static let noAnswer = "No"
        public static let continueAnswer = "Continue"
    }
    
    struct Storyboard{
        public static let navigationMenu = "NavigationMenu"
        public static let listNavigation = "ListNavigation"
        public static let articlesNavigation = "ArticlesNavigation"
        public static let configuration = "Configuration"
        public static let stores = "Stores"
    }
    
    struct NavigationMenu{
        public static let listItem = "Listas"
        public static let storeItem = "Tiendas"
        public static let articleItem = "Articulos"
        public static let configurationItem = "Configuracion"
    }
    
    struct Configuration{
        public static let soundEnable = "sharedPrefSoundEnabled"
    }
}

//Popup Response
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
    public static let menuItemTableViewCell = "MenuItemTableViewCell"
    public static let compareTableViewCell = "CompareTableViewCell"
    public static let headerCompareTableViewCell = "HeaderCompareTableViewCell"
    public static let storeTableViewCell = "StoreTableViewCell"
    public static let articleTableViewCell = "ArticleTableViewCell"
    
}

//Segues
struct Segues{
    public static let toStoresFromCreateList = "toStoresFromCreateList"
    public static let toArticleFromList = "toArticleFromList"
    public static let toListDetailFromLists = "toListDetailFromLists"
    public static let toCompareFromArticle = "toCompareFromArticle"
    public static let toArticleDetailFromArticles = "toArticleDetailFromArticles"
    public static let toCompareFromArticleDetail = "toCompareFromArticleDetail"
}

//Images
struct ImageNames{
    public static let listIcon = "shopingCartIconWhite"
    public static let configurationIcon = "gearIconWhite"
    public static let storeIcon = "storeIconWhite"
    public static let articleIcon = "articleIconWhite"
}
