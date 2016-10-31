import Foundation
import CoreData
import UIKit

class JakPersistence {
    
    static let instance = JakPersistence()
    
    let appDelegate:AppDelegate
    let managedContext:NSManagedObjectContext
    
    let boardEntity:NSEntityDescription
    let listEntity:NSEntityDescription
    let cardEntity:NSEntityDescription
    
    let entities:[NSEntityDescription]
    
    static func get() -> JakPersistence {
        return instance
    }
    
    fileprivate init() {
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        managedContext = appDelegate.managedObjectContext
        
        boardEntity = NSEntityDescription.entity(forEntityName: "Board", in: managedContext)!
        listEntity = NSEntityDescription.entity(forEntityName: "List", in: managedContext)!
        cardEntity = NSEntityDescription.entity(forEntityName: "Card", in: managedContext)!
        
        entities = [boardEntity, listEntity, cardEntity]
    }
    
    func reset() {
        let coord = appDelegate.persistentStoreCoordinator
        
        for entity in entities {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity.name!)
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            
            do {
                try coord.execute(deleteRequest, with: managedContext)
                let _ = save()
            } catch let error as NSError {
                debugPrint(error)
            }
        }
    }
    
    func save() -> Bool {
        do {
            try managedContext.save()
            return true
        } catch let error as NSError {
            print("error while saving managedContext \(error)")
            return false
        }
    }
    
    func newCard(title: String, desc: String, card_id: String, owner: String, list_id: String) -> NSManagedObject? {
        if containsCard(card_id: card_id, list_id: list_id) {
            print("Card \(title) is already saved with ID \(card_id)")
        } else {
            let card = NSManagedObject(entity: cardEntity, insertInto: managedContext)
            card.setValue(list_id, forKey: "list_id")
            card.setValue(card_id, forKey: "card_id")
            card.setValue(title, forKey: "title")
            card.setValue(desc, forKey: "desc")
            card.setValue(owner, forKey: "owner")
            
            if save() {
                return card
            }
        }
        
        return nil
    }
    
    func containsCard(card_id: String, list_id: String) -> Bool {
        let cards = getCards(list_id)
        if cards != nil {
            for card in cards! {
                let cardId = card.value(forKey: "card_id") as? String
                if cardId == card_id {
                    return true
                }
            }
        }
        
        return false;
    }
    
    func getCards(_ list_id: String) -> [NSManagedObject]? {
        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Card")
        let predicate = NSPredicate(format: "list_id = %@", list_id)
        fetchRequest.predicate = predicate
        
        do {
            let results = try managedContext.fetch(fetchRequest)
            return results as? [NSManagedObject]
        } catch let error as NSError {
            print(error)
        }
        
        return nil
    }
    
    func cleanupBoards() {
        delete("Board")
    }
    
    func cleanupLists(_ list_id: String) {
        delete("List", qualifier: "list_id = %@", key: list_id)
        cleanupCards(list_id)
    }
    
    func cleanupCards(_ list_id: String) {
        delete("Card", qualifier: "list_id = %@", key: list_id)
    }
    
    func newList(name: String, list_id: String, board_id: String, owner: String) -> NSManagedObject? {
        if containsList(list_id: list_id, board_id: board_id) {
            print("List \(name) is already saved with ID \(list_id)")
        } else {
            let list = NSManagedObject(entity: listEntity, insertInto: managedContext)
            list.setValue(name, forKey: "name")
            list.setValue(list_id, forKey: "list_id")
            list.setValue(board_id, forKey: "board_id")
            list.setValue(owner, forKey: "owner")
            
            if save() {
                return list
            }
        }
        
        return nil
    }
    
    func containsList(list_id: String, board_id: String) -> Bool {
        let lists = getLists(board_id)
        if lists != nil {
            for list in lists! {
                let listId = list.value(forKey: "list_id") as! String
                if list_id == listId {
                    return true
                }
            }
        }
        
        return false
    }
    
    func getAllLists() -> [NSManagedObject]? {
        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "List")
        
        do {
            let results = try managedContext.fetch(fetchRequest)
            return results as? [NSManagedObject]
        } catch let error as NSError {
            print(error)
        }
        
        return nil
    }
    
    func getLists(_ board_id: String) -> [NSManagedObject]? {
        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "List")
        let predicate = NSPredicate(format: "board_id = %@", board_id)
        
        fetchRequest.predicate = predicate
        
        do {
            let results = try managedContext.fetch(fetchRequest)
            return results as? [NSManagedObject]
        } catch let error as NSError {
            print(error)
        }
        
        return nil
    }
    
    func newBoard(name: String, board_id: String) -> NSManagedObject? {
        if containsBoard(board_id: board_id) {
            print("Board \(name) is already saved with ID \(board_id)")
        } else {
            let board = NSManagedObject(entity: boardEntity, insertInto: managedContext)
            board.setValue(name, forKey: "name")
            board.setValue(board_id, forKey: "board_id")
            
            if save() {
                return board
            }
        }
        
        return nil
    }
    
    func getBoards() -> [NSManagedObject]? {
        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Board")
        do {
            let results = try managedContext.fetch(fetchRequest)
            return results as? [NSManagedObject]
        } catch let error as NSError {
            print("Error \(error)")
        }
        
        return nil
    }
    
    func containsBoard(board_id: String) -> Bool {
        let boards = getBoards()
        if (boards != nil) {
            for board in boards! {
                let boardId = board.value(forKey: "board_id") as! String
                if board_id == boardId {
                    return true
                }
            }
        }
        return false
    }
    
    func deleteBoard(board_id: String) {
        if containsBoard(board_id: board_id) {
            for list in getLists(board_id)! {
                deleteList(list_id: list.value(forKey: "list_id") as! String, board_id: board_id)
            }
            
            delete("Board", qualifier: "board_id = %@", key: board_id)
        }
    }
    
    func deleteList(list_id: String, board_id: String) {
        if containsList(list_id: list_id, board_id: board_id) {
            for card in getCards(list_id)! {
                delete("Card", qualifier: "list_id = %@", key: card.value(forKey: "list_id") as? String)
            }
        }
        
        delete("List", qualifier: "list_id = %@", key: list_id)
    }
    
    fileprivate func delete(_ entityName: String) {
        delete(entityName, qualifier: nil, key: nil)
    }
    
    fileprivate func delete(_ entityName: String, qualifier: String?, key: String?) {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: entityName)
        
        if (qualifier != nil) {
            let predicate = NSPredicate(format: qualifier!, key!)
            fetchRequest.predicate = predicate
        }
        
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try managedContext.execute(deleteRequest)
        } catch let error as NSError {
            debugPrint(error)
        }
    }
    
//    func saveBoards() -> [] {
//        
//    }
}
