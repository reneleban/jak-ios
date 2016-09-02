import Foundation

enum JakMethod: String {
    
    case POST = "POST"
    case GET = "GET"
    case PUT = "PUT"
    case DELETE = "DELETE"
}

class JakUrl {
    
    let url: String
    let method: JakMethod
    
    init(url: String, method: JakMethod) {
        self.url = url
        self.method = method
    }
    
    func getUrl() -> String {
        return self.url
    }
    
    func getMethod() -> String {
        return self.method.rawValue
    }
}

class JakResponse {
    
    let object: AnyObject?
    let statusCode: Int
    
    init(object: AnyObject?, statusCode: Int) {
        self.object = object
        self.statusCode = statusCode
    }
}

class JakLogin {
    
    static func validate(token: String, handler: (response: JakResponse) -> ()) {
        let validateUrl = JakUrl(url: UrlBuilder(service: Services.LOGIN).a("login").a("validate").a(token).create(), method: JakMethod.GET)
        JsonConnection(jakUrl: validateUrl).send { (jakResponse) in handler(response: jakResponse) }
    }
    
    static func login(email: String, password: String, handler: (response: JakResponse) -> ()) {
        let loginUrl = JakUrl(url: UrlBuilder(service: Services.LOGIN).a("login").create(), method: JakMethod.GET)
        let connection = JsonConnection(jakUrl: loginUrl)
        connection.basicAuth(email, password: password)
        connection.send { (jakResponse) in handler(response: jakResponse) }
    }
    
    static func register(email: String, password: String, handler: (response: JakResponse) -> ()) {
        let registerUrl = JakUrl(url: UrlBuilder(service: Services.LOGIN).a("login").create(), method: JakMethod.POST)
        let connection = JsonConnection(jakUrl: registerUrl)
        connection.addParameter("username", value: email)
        connection.addParameter("password", value: password)
        connection.send { (jakResponse) in handler(response: jakResponse) }
    }
}

class JakBoard {
    
    static func loadBoards(token: String, handler: (response: JakResponse) -> ()) {
        let getBoardUrl = JakUrl(url: UrlBuilder(service: Services.BOARD).a("board").a(token).create(), method: JakMethod.GET)
        JsonConnection(jakUrl: getBoardUrl).send { (jakResponse) in handler(response: jakResponse) }
    }
    
    static func addBoard(title: String, token: String, handler: (response: JakResponse) -> ()) {
        let addBoardUrl = JakUrl(url: UrlBuilder(service: Services.BOARD).a("board").a(token).create(), method: JakMethod.PUT)
        let connection = JsonConnection(jakUrl: addBoardUrl)
        connection.addParameter("name", value: title)
        connection.send { (jakResponse) in handler(response: jakResponse) }
    }
    
    static func deleteBoard(board_id: String, token: String, handler: (response: JakResponse) -> ()) {
        let deleteBoardUrl = JakUrl(url: UrlBuilder(service: Services.BOARD).a("board").a(token).a(board_id).create(), method: JakMethod.DELETE)
        JsonConnection(jakUrl: deleteBoardUrl).send { (jakResponse) in handler(response: jakResponse) }
    }
}

class JakList {
    
    static func loadLists(board_id: String, token: String, handler: (response: JakResponse) -> ()) {
        let getListsUrl = JakUrl(url: UrlBuilder(service: Services.LIST).a("lists").a("list").a(token).a(board_id).create(), method: JakMethod.GET)
        JsonConnection(jakUrl: getListsUrl).send { (jakResponse) in handler(response: jakResponse) }
    }
    
    static func addList(name: String, board_id: String, token: String, handler: (response: JakResponse) -> ()) {
        let addListUrl = JakUrl(url: UrlBuilder(service: Services.LIST).a("lists").a("board").a(token).a(board_id).create(), method: JakMethod.POST)
        let connection = JsonConnection(jakUrl: addListUrl)
        connection.addParameter("name", value: name)
        connection.send { (jakResponse) in handler(response: jakResponse) }
    }
    
    static func deleteList(list_id: String, token: String, handler: (response: JakResponse) -> ()) {
        let deleteListUrl = JakUrl(url: UrlBuilder(service: Services.LIST).a("lists").a("list").a(token).a(list_id).create(), method: JakMethod.DELETE)
        JsonConnection(jakUrl: deleteListUrl).send { (jakResponse) in handler(response: jakResponse) }
    }
}

class JakCard {
    
    static func loadCards(list_id: String, token: String, handler: (response: JakResponse) -> ()) {
        let getCardsUrl = JakUrl(url: UrlBuilder(service: Services.CARD).a("cards").a(token).a(list_id).create(), method: JakMethod.GET)
        JsonConnection(jakUrl: getCardsUrl).send { (jakResponse) in handler(response: jakResponse) }
    }
    
    static func addCard(title: String, description: String, list_id: String, token: String, handler: (response: JakResponse) -> ()) {
        let addCardUrl = JakUrl(url: UrlBuilder(service: Services.CARD).a("cards").a(token).a(list_id).create(), method: JakMethod.POST)
        let connection = JsonConnection(jakUrl: addCardUrl)
        connection.addParameter("name", value: title)
        connection.addParameter("description", value: description)
        connection.send { (jakResponse) in handler(response: jakResponse) }
    }
    
    static func deleteCard(card_id: String, token: String, handler: (response: JakResponse) -> ()) {
        let deleteCardUrl = JakUrl(url: UrlBuilder(service: Services.CARD).a("cards").a(token).a(card_id).create(), method: JakMethod.DELETE)
        JsonConnection(jakUrl: deleteCardUrl).send { (jakResponse) in handler(response: jakResponse) }
    }
    
    static func deleteCards(list_id: String, token: String, handler: (response: JakResponse) -> ()) {
        let deleteCardsUrl = JakUrl(url: UrlBuilder(service: Services.CARD).a("cards").a("list").a(token).a(list_id).create(), method: JakMethod.DELETE)
        JsonConnection(jakUrl: deleteCardsUrl).send { (jakResponse) in handler(response: jakResponse) }
    }
}
