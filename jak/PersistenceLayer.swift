import Foundation
import CoreData
import UIKit

class JakPersistence {
    
    let appDelegate:AppDelegate
    let managedContext:NSManagedObjectContext
    
    fileprivate init() {
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        managedContext = appDelegate.managedObjectContext
    }
    
    func boards() -> [NSManagedObject]? {
        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Board")
        do {
            let results = try managedContext.execute(fetchRequest)
            return results as! [NSManagedObject]
        } catch let error as NSError {
            print("Error \(error)")
        }
        
        return nil
    }
}
