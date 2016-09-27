import Foundation
import CoreData
import UIKit

class JakPersistence {
    
    static let instance = JakPersistence()
    
    let appDelegate:AppDelegate
    let managedContext:NSManagedObjectContext
    
    let boardEntity:NSEntityDescription
    
    static func get() -> JakPersistence {
        return instance
    }
    
    fileprivate init() {
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        managedContext = appDelegate.managedObjectContext
        
        boardEntity = NSEntityDescription.entity(forEntityName: "Board", in: managedContext)!
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
    
    func newBoard(name: String, board_id: String) -> NSManagedObject? {
        let board = NSManagedObject(entity: boardEntity, insertInto: managedContext)
        board.setValue(name, forKey: "name")
        board.setValue(board_id, forKey: "board_id")
        
        if save() {
            return board
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
    
//    func saveBoards() -> [] {
//        
//    }
}
