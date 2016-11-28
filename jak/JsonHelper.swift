import Foundation
import UIKit

enum JakMethod: String {
    
    case POST = "POST"
    case GET = "GET"
    case PUT = "PUT"
    case DELETE = "DELETE"
}

class JakUrl {
    
    let url: UrlBuilder
    let method: JakMethod
    
    init(url: UrlBuilder, method: JakMethod) {
        self.url = url
        self.method = method
    }
    
    func getUrl() -> UrlBuilder {
        return self.url
    }
    
    func getMethod() -> String {
        return self.method.rawValue
    }
}

class JakResponse {
    
    let object: AnyObject?
    let statusCode: Int
    var internetConnection = true
    
    init(object: AnyObject?, statusCode: Int) {
        self.object = object
        self.statusCode = statusCode
    }
    
    func internetConnectionUnavailable() {
        self.internetConnection = false
    }
}

class JakBase {
    
    static func isReachable() -> Bool {
        return ReachabilityObserver.isConnected()
    }
    
    static func waiting(_ message: String) -> UIAlertController {
        let loadingAlertController = UIAlertController(title: message, message: nil, preferredStyle: .alert)
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingAlertController.view.addSubview(activityIndicator)
        let xConstraint = NSLayoutConstraint(item: activityIndicator, attribute: .centerX, relatedBy: .equal, toItem: loadingAlertController.view, attribute: .centerX, multiplier: 1, constant: 0)
        let yConstraint = NSLayoutConstraint(item: activityIndicator, attribute: .centerY, relatedBy: .equal, toItem: loadingAlertController.view, attribute: .centerY, multiplier: 1.4, constant: 0)
        NSLayoutConstraint.activate([ xConstraint, yConstraint])
        activityIndicator.isUserInteractionEnabled = false
        activityIndicator.startAnimating()
        let height: NSLayoutConstraint = NSLayoutConstraint(item: loadingAlertController.view, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 80)
        loadingAlertController.view.addConstraint(height);
        AppDelegate.navController!.present(loadingAlertController, animated: true, completion: nil)
        return loadingAlertController
    }
}

class JakLogin: JakBase {
    
    static func validate(_ token: String, handler: @escaping (_ response: JakResponse) -> ()) {
        let validateUrl = JakUrl(url: UrlBuilder(Services.LOGIN).a("login").a("validate").a(token), method: JakMethod.GET)
        JsonConnection(jakUrl: validateUrl).send { (jakResponse) in handler(jakResponse) }
    }
    
    static func login(_ email: String, password: String, handler: @escaping (_ response: JakResponse) -> ()) {
        let loginUrl = JakUrl(url: UrlBuilder(Services.LOGIN).a("login"), method: JakMethod.GET)
        let connection = JsonConnection(jakUrl: loginUrl)
        connection.basicAuth(email, password: password)
        connection.send { (jakResponse) in handler(jakResponse) }
    }
    
    static func register(_ email: String, password: String, handler: @escaping (_ response: JakResponse) -> ()) {
        let registerUrl = JakUrl(url: UrlBuilder(Services.LOGIN).a("login"), method: JakMethod.POST)
        let connection = JsonConnection(jakUrl: registerUrl)
        connection.addParameter("username", value: email)
        connection.addParameter("password", value: password)
        connection.send { (jakResponse) in handler(jakResponse) }
    }
}

class JakBoard: JakBase {
    
    static func loadBoards(_ token: String, handler: @escaping (_ response: JakResponse) -> ()) {
        let getBoardUrl = JakUrl(url: UrlBuilder(Services.BOARD).a("board").a(token), method: JakMethod.GET)
        JsonConnection(jakUrl: getBoardUrl).send { (jakResponse) in handler(jakResponse) }
    }
    
    static func addBoard(_ title: String, token: String, handler: @escaping (_ response: JakResponse) -> ()) {
        let addBoardUrl = JakUrl(url: UrlBuilder(Services.BOARD).a("board").a(token), method: JakMethod.PUT)
        let connection = JsonConnection(jakUrl: addBoardUrl)
        connection.addParameter("name", value: title)
        connection.send { (jakResponse) in handler(jakResponse) }
    }
    
    static func deleteBoard(_ board_id: String, token: String, handler: @escaping (_ response: JakResponse) -> ()) {
        let deleteBoardUrl = JakUrl(url: UrlBuilder(Services.BOARD).a("board").a(token).a(board_id), method: JakMethod.DELETE)
        JsonConnection(jakUrl: deleteBoardUrl).send { (jakResponse) in handler(jakResponse) }
    }
}

class JakList: JakBase {
    
    static func loadLists(_ board_id: String, token: String, handler: @escaping (_ response: JakResponse) -> ()) {
        let getListsUrl = JakUrl(url: UrlBuilder(Services.LIST).a("lists").a("list").a(token).a(board_id), method: JakMethod.GET)
        JsonConnection(jakUrl: getListsUrl).send { (jakResponse) in handler(jakResponse) }
    }
    
    static func addList(_ name: String, board_id: String, token: String, handler: @escaping (_ response: JakResponse) -> ()) {
        let addListUrl = JakUrl(url: UrlBuilder(Services.LIST).a("lists").a("board").a(token).a(board_id), method: JakMethod.POST)
        let connection = JsonConnection(jakUrl: addListUrl)
        connection.addParameter("name", value: name)
        connection.send { (jakResponse) in handler(jakResponse) }
    }
    
    static func deleteList(_ list_id: String, token: String, handler: @escaping (_ response: JakResponse) -> ()) {
        let deleteListUrl = JakUrl(url: UrlBuilder(Services.LIST).a("lists").a("list").a(token).a(list_id), method: JakMethod.DELETE)
        JsonConnection(jakUrl: deleteListUrl).send { (jakResponse) in handler(jakResponse) }
    }
}

class JakCard: JakBase {
    
    static func loadCards(_ list_id: String, token: String, handler: @escaping (_ response: JakResponse) -> ()) {
        let getCardsUrl = JakUrl(url: UrlBuilder(Services.CARD).a("cards").a(token).a(list_id), method: JakMethod.GET)
        JsonConnection(jakUrl: getCardsUrl).send { (jakResponse) in handler(jakResponse) }
    }
    
    static func addCard(_ title: String, description: String, list_id: String, token: String, handler: @escaping (_ response: JakResponse) -> ()) {
        let addCardUrl = JakUrl(url: UrlBuilder(Services.CARD).a("cards").a(token).a(list_id), method: JakMethod.POST)
        let connection = JsonConnection(jakUrl: addCardUrl)
        connection.addParameter("name", value: title)
        connection.addParameter("description", value: description)
        connection.send { (jakResponse) in handler(jakResponse) }
    }
    
    static func deleteCard(_ card_id: String, token: String, handler: @escaping (_ response: JakResponse) -> ()) {
        let deleteCardUrl = JakUrl(url: UrlBuilder(Services.CARD).a("cards").a(token).a(card_id), method: JakMethod.DELETE)
        JsonConnection(jakUrl: deleteCardUrl).send { (jakResponse) in handler(jakResponse) }
    }
    
    static func deleteCards(_ list_id: String, token: String, handler: @escaping (_ response: JakResponse) -> ()) {
        let deleteCardsUrl = JakUrl(url: UrlBuilder(Services.CARD).a("cards").a("list").a(token).a(list_id), method: JakMethod.DELETE)
        JsonConnection(jakUrl: deleteCardsUrl).send { (jakResponse) in handler(jakResponse) }
    }
}
