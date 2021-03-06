import Foundation
import CoreData

class Prefetcher {
    
    fileprivate static let instance = Prefetcher()
    
    static func get() -> Prefetcher {
        return instance
    }
    
    /********/
    
    fileprivate let persistence = JakPersistence.get()
    fileprivate let token:String
    fileprivate let keychain = JakKeychainHelper.keychain
    fileprivate var loginController:LoginController?
    
    fileprivate var showBoardControllerCalled = false
    
    fileprivate init() {
        if UserData.getToken() != nil {
            token = UserData.getToken()!
        } else {
            token = ""
        }
    }
    
    fileprivate func isConnected() -> Bool {
        return ReachabilityObserver.isConnected()
    }
    
    func prefetch(_ loginController: LoginController) {
        self.loginController = loginController
        
        if isConnected() {
            JakPersistence.get().reset()
            prefetchBoards()
        }
    }
    
    func prefetchBoards(handler: @escaping () -> ()) {
        if isConnected() {
            JakBoard.loadBoards(token, handler: { (response: JakResponse) in
                if let boards = response.object as? [[String:Any]] {
                    for board in boards {
                        let id = self.asString(board, key: "board_id")
                        let name = self.asString(board, key: "name")
                        let _ = self.persistence.newBoard(name: name, board_id: id)
                    }
                    
                    self.prefetchLists() {
                        handler()
                    }
                }
            })
        }
    }
    
    func prefetchBoards() {
        prefetchBoards() {}
    }
    
    func prefetchLists(handler: @escaping () -> ()) {
        if isConnected() {
            let boards = persistence.getBoards()
            for board in boards! {
                let id = asString(board, key: "board_id")
                
                JakList.loadLists(id, token: token, handler: { (response: JakResponse) in
                    if let lists = response.object as? [[String:Any]] {
                        for list in lists {
                            let list_id = self.asString(list, key: "list_id")
                            let name = self.asString(list, key: "name")
                            let board_id = self.asString(list, key: "board_id")
                            let owner = self.asString(list, key: "owner")
                            
                            let _ = self.persistence.newList(name: name, list_id: list_id, board_id: board_id, owner: owner)
                            
                            self.prefetchCards(list_id) {
                                handler()
                            }
                        }
                    }
                })
            }
        }
    }
    
    func prefetchLists() {
        prefetchLists() {}
    }
    
    func prefetchCards(_ list_id: String, handler: @escaping () -> ()) {
        if isConnected() {
            JakCard.loadCards(list_id, token: token, handler: { (response: JakResponse) in
                if let cards = response.object as? [[String:Any]] {
                    for card in cards {
                        let name = self.asString(card, key: "name")
                        let description = self.asString(card, key: "description")
                        let card_id = self.asString(card, key: "card_id")
                        let owner = self.asString(card, key: "owner")
                        let list_id = self.asString(card, key: "list_id")
                        
                        let _ = self.persistence.newCard(title: name, desc: description, card_id: card_id, owner: owner, list_id: list_id)
                    }
                    
                    handler()
                    
                    if (!self.showBoardControllerCalled) {
                        self.showBoardControllerCalled = true
                        self.loginController?.showBoardViewController()
                    }
                }
            })
        }
    }
    
    func prefetchCards(_ list_id: String) {
        prefetchCards(list_id, handler: {})
    }
    
    private func asString(_ object: NSManagedObject, key: String) -> String {
        return object.value(forKey: key) as! String
    }
    
    private func asString(_ object:[String:Any], key: String) -> String {
        return object[key] as! String
    }
}
