import Foundation
import UIKit

class ListPageViewController : UIPageViewController, UIPageViewControllerDataSource {
    
    let token = UserData.token!
    let boardId = (UserData.selectedBoard?.board_id)!
    
    var lists:[List] = []
    
    override func viewDidLoad() {
        self.dataSource = self
        
        loadAllLists()
    }
    
    func getListController(list: List, index: Int) -> ListViewController {
        return ListViewController(list: list, index: index)
    }
    
    func loadAllLists() {
        let jsonConn = JsonConnection(url: Services.LIST.rawValue + "list/" + token + "/" + boardId, httpMethod: "GET")
        jsonConn.send { (object, statusCode) -> Void in
            print("\(statusCode)")
            print("\(object)")
            
            if let rows = object as? NSArray {
                for row in rows {
                    let list = List(list_id: row["list_id"] as! String, board_id: row["board_id"] as! String, name: row["name"] as! String, owner: row["owner"] as! String)
                    self.lists.append(list)
                }
                
                dispatch_async(dispatch_get_main_queue(), {
                    let list = self.lists[0]
                    self.title = (UserData.selectedBoard?.name)! + " - " + list.name
                    self.setViewControllers([self.getListController(list, index: 0)], direction: .Forward, animated: true, completion: nil)
                })
            }
        }
    }
    
    @IBAction func add(sender: AnyObject) {
        var inputTextField: UITextField?
        
        let listPrompt = UIAlertController(title: nil, message: "Enter a list name", preferredStyle: .Alert)
        listPrompt.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: nil))
        listPrompt.addAction(UIAlertAction(title: "Add", style: .Default, handler: { (action) -> Void in
            print("Adding list \(inputTextField?.text)")
            self.addList(inputTextField!.text!)
        }))
        
        listPrompt.addTextFieldWithConfigurationHandler({(textField: UITextField!) in
            textField.placeholder = "List name ..."
            inputTextField = textField
        })
        
        self.presentViewController(listPrompt, animated: true, completion: nil)
    }
    
    func addList(name: String) {
        let jsonConn = JsonConnection(url: Services.LIST.rawValue + "board/" + token + "/" + boardId + "/" + name, httpMethod: "PUT")
        jsonConn.send { (object, statusCode) -> Void in
            print("\(statusCode)")
            print("\(object)")
        }
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        return nil;
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        let listController = viewController as! ListViewController
        let index = listController.getIndex()
        
        print("\(index) \(lists.count)")
        
        if index > 0 && index < lists.count {
            self.title = (UserData.selectedBoard?.name)! + " - " + listController.getList().name
            let list = lists[index]
            return getListController(list, index: index)
        }
        
        return nil
    }
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return lists.count
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        return 0
    }
}