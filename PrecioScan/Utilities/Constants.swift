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
    public static let remoteStoreCell = "RemoteStoreCellIdentifier"
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
    
    struct Login {
        public static let completeFields = "Debes completar los campos para continuar"
        public static let wrongPassword = "Password incorrecto"
        public static let invalidEmail = "Email invalido"
        public static let userNotFound = "Usuario no encontrado, por favor verifica que la direccion de correo sea correcta"
    }
    
    struct CreateAccount{
        public static let passwordsNeedToMatch = "Las contraseñas deben de coinicidir"
        public static let allFieldsCompleted = "Todos los campos deben de estar llenos"
        public static let passwordGreaterLength = "La contraseña debe ser mayor a 8 caracteres"
        public static let usersaved = "Cuenta de usuario creada.\nRevisa tu correo electronico que porporcionaste, te hemos enviado un correo para que verifiques tu cuenta."
        public static let verificationEmailError = "Hubo un problema al enviarte el correo de verificación"
    }
    
    struct RecoverPassword {
        public static let emailMissing = "Debes introducir un correo electronico"
        public static let recoveryEmailSent = "Se ha enviado un correo de recuperacion de contraseña a la dirección de correo electronico que especificaste"
    }
    struct Generic{
        public static let genericError = "Ocurrion un problema, intentalo de nuevo"
        public static let networkError = "Ocurrio un problema con la red, verifica tu conexión y vuelve a intentarlo"
    }
    
    struct Profile{
        public static let completeName = "El nombre no debe estar vacio"
    }
}

struct Constants {
    struct CreateList {
        public static let addStoreText = "Buscar y agregar tienda nueva..."
        public static let selectStoreText = "Seleccionar una tienda"
        public static let createListTItle = "Crear Lista"
        public static let listTitle = "Detalle de Lista"
        public static let deleteCellText = "Borrar"
        struct Popup {
            public static let listSaved = "Lista guardada!"
        }
    }
    
    struct Lists {
        struct Popup {
            public static let listRestriction = "Para poder agregar mas listas debes convertirte en usuario Premium comprando tu suscripción. Quieres ir a la seccion de compra?"
        }
    }
    
    struct AddArticle {
        public static let scanArticleCodeText = "Escabea el código de barras o introduce el código del artículo"
        public static let articleFoundText = "Articulo encontrado!"
        public static let articleNotFoundText = "Articulo no encontrado.\nSe creará un articulo nuevo."
        struct Popup {
            public static let addMoreArticlesMessage = "Deseas seguir agregando mas articulos?"
            public static let articleSavedTitle = "Articulo Guardado!"
            public static let photoAlreadySavedTitle = "Foto Guardada"
            public static let photoAlreadySavedMessage = "Ya hay una foto guardada para este articulo. Te gustaria verla o tomar una nueva?"
            public static let subscriptionRestriction = "Para poder comparar los precios anteriores de este articulo debes convertirte en usuario Premium comprando tu suscripción. Quieres ir a la sección de compra?"
            public static let photoSubscriptionRestriction = "Para poder tomar una foto de este articulo debes convertirte en usuario Premium comprando tu suscripción. Quieres ir a la seccion de compra?"
        }
    }
    
    struct CreateStore{
        public static let fromMenu = "ComeFromMenu"
        public static let fromList = "ComeFromList"
        public static let selectStateText = "Selecciona un estado"
        public static let searchBarPlaceholder = "Buscar y agregar una tienda"
        struct Popup {
            public static let storeSaved = "Tienda guardada!"
            public static let attentionTitle = "Atención!"
            public static let willDeleteStoreMessage = "Al borrar esta tienda, tambien se borraran sus listas asociadas a ella, estas de acuerdo?"
            public static let storeAlreadySaved = "Ya habías guardado esta tienda antes!"
        }
    }
    
    struct SaveNewStore {
        public static let locationPlaceholder = "Ej. Av Mexico"
    }
    
    struct SearchStore {
        public static let selectStateText = "De que estado?"
    }
    
    struct Articles {
        public static let searchBarPlaceholder = "Buscar Articulo"
    }
    
    struct ArticleDetail {
        struct Poppup {
            public static let articleUpdated = "Articulo actualizado"
            public static let subscriptionRestriction = "Para poder comparar los precios anteriores de este articulo debes convertirte en usuario Premium comprando tu suscripción. Quieres ir a la sección de compra?"
        }
    }
    
    struct Subscription {
        public static let buyButtonTitle = "Comprar por "
    }
    
    struct Compare {
        public static let historyTitle = "Historial:"
    }
    
    struct Popup {
        struct Buttons {
            public static let yesAnswer = "Si"
            public static let noAnswer = "No"
            public static let continueAnswer = "Continue"
            public static let showPhoto = "Ver"
            public static let takePhoto = "Tomar"
            public static let goToPremium = "Comprar!"
            public static let retry = "Reintentar"
        }
        struct Titles {
            public static let ready = "Listo!"
            public static let attention = "Atención"
            public static let premium = "Premium"
        }
        struct Messages {
            public static let purchaseMessage = "Para"
        }
    }
    
    struct Storyboard{
        public static let navigationMenu = "NavigationMenu"
        public static let listNavigation = "ListNavigation"
        public static let articlesNavigation = "ArticlesNavigation"
        public static let configuration = "Configuration"
        public static let navigationStore = "NavigationStore"
        public static let subscriptionNavigation = "SubscriptionNavigation"
        public static let profile = "Profile"
    }
    
    struct NavigationMenu{
        public static let listItem = "Inicio"
        public static let storeItem = "Tiendas"
        public static let articleItem = "Articulos"
        public static let configurationItem = "Configuracion"
        public static let subscritpionIten = "Suscripción"
        public static let logoutItem = "Cerrar Sesión"
    }
    
    struct Configuration{
        public static let soundEnable = "sharedPrefSoundEnabled"
        public static let photosDeletedMessage = "Todas las fotos fueron borradas con exito!"
        public static let noPhotosToDeleteMessage = "No hay fotos guardadas"
    }
    
    struct Profile {
        public static let infoUpdated = "Información Actualizada!"
    }
    
    struct User{
        struct Keys {
            public static let isLoggedIn = "userIsLoggedIn"
        }
    }
    
    struct Files {
        public static let photosFolder = "photos"
        public static let profilePhotoFolder = "profile"
        public static let photoExtension = ".png"
    }
    
    struct RecoverPassword{
        struct Messages{
            public static let emailFieldCompleted = "Debe ingresar el correo electronico"
            public static let wrongEmail = "El correo electronico no existe"
        }
    }
    
    struct InAppPurchasesManager{
        public static let product = "com.felixolivares.PrecioScan.PremiumSubscription"
    }
    
    //Admob
    struct Admob{
        public static let appID = "ca-app-pub-3913769475917328~5547690405"
        public static let bannerTestId = "ca-app-pub-3940256099942544/2934735716"
        public static let bannerMainListId = "ca-app-pub-3913769475917328/6205687021"
        public static let bannerStoresListId = "ca-app-pub-3913769475917328/9766492234"
        public static let bannerSearchStoresSmallId = "ca-app-pub-3913769475917328/1720960184"
        public static let bannerSeachStoresIABMedium = "ca-app-pub-3913769475917328/2014148819"
    }
}

//Popup Response
struct PopupResponse {
    public static let Accept = "PopupAccept"
    public static let Decline = "PopupDecline"
    public static let Continue = "PopupContinue"
    public static let Show = "ShowPhoto"
    public static let Take = "TakePhoto"
}

//Identifiers
struct Identifiers {
    struct Notifications{
        public static let idArticleFound = "NotificationIdArticleFound"
        public static let purchaseComplete = "NotificationPurchaseComplete"
        public static let connectionChanged = "NotificationConnectionChanged"
    }
    public static let codeIdentifier = "code"
    public static let productIdentifier = "product"
    public static let itemListTableViewCell = "ItemListTableViewCell"
    public static let listTableViewCell = "ListTableViewCell"
    public static let menuItemTableViewCell = "MenuItemTableViewCell"
    public static let compareTableViewCell = "CompareTableViewCell"
    public static let headerCompareTableViewCell = "HeaderCompareTableViewCell"
    public static let storeTableViewCell = "StoreTableViewCell"
    public static let articleTableViewCell = "ArticleTableViewCell"
    public static let remoteStoreTableViewCell = "RemoteStoreTableViewCell"
    
}

//Segues
struct Segues{
    public static let toStoresFromCreateList = "toStoresFromCreateList"
    public static let toArticleFromList = "toArticleFromList"
    public static let toListDetailFromLists = "toListDetailFromLists"
    public static let toCompareFromArticle = "toCompareFromArticle"
    public static let toArticleDetailFromArticles = "toArticleDetailFromArticles"
    public static let toCompareFromArticleDetail = "toCompareFromArticleDetail"
    public static let toSearchFromStores = "toSearchFromStores"
    public static let unwindToList = "unwindToList"
    public static let unwindToListFromSearch = "unwindToListFromSearch"
    public static let toSuscribeFromLists = "toSuscribeFromLists"
    public static let toNewListFromLists = "toNewListFromLists"
    public static let toSubscribeFromArticleDetail = "toSubscribeFromArticleDetail"
    public static let toSubscriptionFromAddArticle = "toSubscriptionFromAddArticle"
}

//Images
struct ImageNames{
    public static let listIcon = "shopingCartIconWhite"
    public static let configurationIcon = "gearIconWhite"
    public static let storeIcon = "storeIconWhite"
    public static let articleIcon = "articleIconWhite"
    public static let logoutIcon = "logoutIconWhite"
    public static let subscriptionIcon = "subscriptionIocn"
    public static let crwonIconWhite = "crownIconWhite"
    public static let subscribeBannerGreen = "subscribeBannerGreen"
    public static let profilePlaceholder = "profilePlaceholder"
}

//States
struct States {
    public static let aguascalientes = "Aguascalientes"
    public static let bajaCalifornia = "Baja California"
    public static let bajaCaliforniaSur = "Baja California Sur"
    public static let campeche = "Campeche"
    public static let chiapas = "Chiapas"
    public static let chihuahua = "Chihuahua"
    public static let cdmx = "Ciudad de Mexico"
    public static let coahuila = "Coahuila"
    public static let colima = "Colima"
    public static let durango = "Durango"
    public static let guanajuato = "Guanajuato"
    public static let guerrero = "Guerrero"
    public static let hidalgo = "Hidalgo"
    public static let jalisco = "Jalisco"
    public static let edoMex = "Estado de México"
    public static let michoacan = "Michoacán"
    public static let morelos = "Morelos"
    public static let nayarit = "Nayarit"
    public static let nuevoLeon = "Nuevo Leon"
    public static let oaxaca = "Oaxaca"
    public static let puebla = "Puebla"
    public static let queretaro = "Querétaro"
    public static let quintanaroo = "Quintana Roo"
    public static let slp = "San Luis Potosí"
    public static let sinaloa = "Sinaloa"
    public static let sonora = "Sonora"
    public static let tabasco = "Tabasco"
    public static let tamaulipas = "Tamaulipas"
    public static let tlaxcala = "Tlaxcala"
    public static let veracruz = "Veracruz"
    public static let yucatan = "Yucatan"
    public static let zacatecas = "Zacatecas"
    public static let all = "Todos"
    func allStates() -> [String]{
        let states = [States.all, States.aguascalientes, States.bajaCalifornia, States.bajaCaliforniaSur, States.campeche, States.chiapas, States.chihuahua, States.cdmx, States.coahuila, States.colima, States.durango, States.guanajuato, States.guerrero, States.hidalgo, States.jalisco, States.edoMex, States.michoacan, States.morelos, States.nayarit, States.nuevoLeon, States.oaxaca, States.puebla, States.queretaro, States.quintanaroo, States.slp, States.sinaloa, States.sonora, States.tabasco, States.tamaulipas, States.tlaxcala, States.veracruz, States.yucatan, States.zacatecas]
        return states
    }
}

//Firebase
struct FRTable {
    public static let user = "user"
    public static let article = "article"
    public static let store = "store"
    public static let list = "list"
    public static let itemList = "itemList"
    
}

struct FRAttribute {
    public static let username = "username"
    public static let email = "email"
    public static let code = "code"
    public static let name = "name"
    public static let date = "date"
    public static let photoName = "photoName"
    public static let quantity = "quantity"
    public static let unitaryPrice = "unitaryPrice"
    public static let article = "article"
    public static let list = "list"
    public static let user = "user"
    public static let store = "store"
    public static let nameSearch = "nameSearch"
    public static let location = "location"
    public static let locationSearch = "locationSearch"
    public static let information = "information"
    public static let state = "state"
    public static let stateSearch = "stateSearch"
    public static let city = "city"
    public static let citySearch = "citySearch"
    public static let uid = "uid"
    public static let itemLists = "itemLists"
}
