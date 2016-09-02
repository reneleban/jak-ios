import Foundation
import UIKit

class ListPageViewController : UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    @IBOutlet weak var addNewCard: UIBarButtonItem!
    @IBOutlet weak var actionButton: UIBarButtonItem!
    
    let token = UserData.token!
    let boardId = (UserData.selectedBoard?.board_id)!
    
    var lists:[List] = []
    var selectedlist:List?
    
    var listControllers:[ListViewController] = []
    
    var swipeEnabled = true
    
    var oldBarButtonItems:[UIBarButtonItem]?
    
    override func viewDidLoad() {
        self.dataSource = self
        self.delegate = self
        
        self.oldBarButtonItems = self.navigationItem.rightBarButtonItems
        
        loadAllLists()
    }
    
    func getListController(list: List, index: Int) -> ListViewController {
        for controller in listControllers {
            if controller.getList().list_id == list.list_id {
                return controller
            }
        }
        
        let newController = ListViewController(list: list, index: index, useStoryboard: self.storyboard!)
        listControllers.append(newController)
        
        return newController
    }
    
    func getListControllers() -> [ListViewController] {
        var controllers:[ListViewController] = []
        var index = 0
        for list in lists {
            controllers.append(getListController(list, index: index))
            index += 1
        }
        return controllers
    }
    
    func cleanUp() {
        listControllers.removeAll()
    }
    
    func loadAllLists() {
        JakList.loadLists(boardId, token: token) { (response) in
            if let rows = response.object as? NSArray {
                self.lists.removeAll()
                
                for row in rows {
                    let list = List(list_id: row["list_id"] as! String, board_id: row["board_id"] as! String, name: row["name"] as! String, owner: row["owner"] as! String)
                    self.lists.append(list)
                }
                
                dispatch_async(dispatch_get_main_queue(), {
                    if self.lists.count > 0 {
                        self.cleanUp()
                        let list = self.lists[0]
                        self.title = list.name
                        self.selectedlist = list
                        let listController = self.getListController(list, index: 0)
                        listController.reloadCards()
                        self.setViewControllers([listController], direction: .Forward, animated: true, completion: nil)
                    } else {
                        self.setViewControllers([(self.storyboard?.instantiateViewControllerWithIdentifier("nolistscontroller"))!], direction: .Forward, animated: true, completion: nil)
                    }
                })
            }
        }
    }
    
    @IBAction func actionButton(sender: AnyObject) {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        actionSheet.addAction(UIAlertAction(title: "New list", style: .Default, handler: { (UIAlertAction) in
            self.addListPrompt()
        }))
        
        if lists.count != 0 {
            actionSheet.addAction(UIAlertAction(title: "Edit mode", style: .Default, handler: { (UIAlertAction) in
                self.switchEditMode()
            }))
            
            actionSheet.addAction(UIAlertAction(title: "Available lists of '" + UserData.selectedBoard!.name + "'", style: .Default, handler: { (UIAlertAction) in
                self.performSegueWithIdentifier("availablelists", sender: self)
            }))
            
            actionSheet.addAction(UIAlertAction(title: "Delete '" + selectedlist!.name + "'", style: .Destructive, handler: { (alert) in
                let alert = UIAlertController(title: "Warning", message: "Your cards will also be removed if you delete this list! Proceed?", preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "Proceed", style: .Destructive, handler: { (UIAlertAction) in
                    self.deleteList()
                }))
                alert.addAction(UIAlertAction(title: "Abort", style: .Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }))
        }
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        self.presentViewController(actionSheet, animated: true, completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let navController = segue.destinationViewController as? UINavigationController
        if let viewController = navController?.topViewController as? AvailableListsController {
            viewController.pageViewController = self
        }
    }
    
    private func switchEditMode() {
        let viewController = getSelectedListController()
        if viewController != nil {
            let currentMode = viewController!.tableView.editing
            viewController!.tableView.setEditing(!currentMode, animated: true)
            
            if !currentMode {
                self.navigationItem.setRightBarButtonItems([UIBarButtonItem(title: "Done", style: .Plain, target: self, action: #selector(finishButtonClicked))], animated: true)
            }
        }
    }
    
    func selectList(list: List) {
        self.selectedlist = list
        let listController = getListController(list, index: 0)
        self.title = list.name
        self.setViewControllers([listController], direction: .Forward, animated: true, completion: nil)
    }
    
    func finishButtonClicked() {
        self.navigationItem.setRightBarButtonItems(self.oldBarButtonItems, animated: true)
        getSelectedListController()!.tableView.setEditing(false, animated: true)
    }
    
    private func getSelectedListController() -> ListViewController? {
        if selectedlist != nil {
            return getListController(selectedlist!, index: 0)
        }
        
        return nil
    }
    
    @IBAction func addNewCard(sender: AnyObject) {
        if lists.count == 0 {
            addListPrompt()
        } else {
            addCardPrompt()
        }
    }
    
    func reloadCards() {
        if selectedlist != nil {
            let currentController = getListController(selectedlist!, index: 0)
            
            dispatch_async(dispatch_get_main_queue(), {
                currentController.reloadCards()
            })
        }
    }
    
    func addCardPrompt() {
        var titleTextField: UITextField?
        
        let listPrompt = UIAlertController(title: nil, message: "Create new card", preferredStyle: .Alert)
        listPrompt.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: nil))
        listPrompt.addAction(UIAlertAction(title: "Add", style: .Default, handler: { (action) -> Void in
            print("Adding list \(titleTextField?.text)")
            self.addCard(titleTextField!.text!, desc: "")
        }))
        
        listPrompt.addTextFieldWithConfigurationHandler({(textField: UITextField!) in
            textField.placeholder = "Card name ..."
            titleTextField = textField
        })
        
        self.presentViewController(listPrompt, animated: true, completion: nil)
    }
    
    func addCard(title: String, desc: String) {
        JakCard.addCard(title, description: description, list_id: selectedlist!.list_id, token: token) { (response) in
            self.reloadCards()
        }
    }
    
    func deleteList() {
        if selectedlist != nil {
            JakCard.deleteCards(selectedlist!.list_id, token: token, handler: { (response) in
                if response.statusCode == 200 {
                    JakList.deleteList(self.selectedlist!.list_id, token: self.token, handler: { (response) in
                        self.loadAllLists()
                        self.selectedlist = nil
                    })
                }
            })
        }
    }
    
    func addListPrompt() {
        var inputTextField: UITextField?
        
        let listPrompt = UIAlertController(title: nil, message: "Enter a list name", preferredStyle: .Alert)
        listPrompt.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: nil))
        listPrompt.addAction(UIAlertAction(title: "Add", style: .Default, handler: { (action) -> Void in
            self.addList(inputTextField!.text!)
        }))
        
        listPrompt.addTextFieldWithConfigurationHandler({(textField: UITextField!) in
            textField.placeholder = "List name ..."
            inputTextField = textField
        })
        
        self.presentViewController(listPrompt, animated: true, completion: nil)
    }
    
    func addList(name: String) {
        JakList.addList(name, board_id: boardId, token: token) { (response) in
            self.loadAllLists()
        }
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        if let listController = viewController as? ListViewController {
            let index = listController.getIndex()
            if index == 0 {
                return nil
            }
            
            let prevIndex = index-1
            let list = lists[prevIndex]
            self.title = list.name
            
            selectedlist = list
            
            let prevController = getListController(list, index: prevIndex)
            prevController.reloadCards()
            return prevController
        }
        
        return nil
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        if let listController = viewController as? ListViewController {
            let index = listController.getIndex()
            if index == lists.count - 1 {
                return nil
            }

            
            let nextIndex = index+1
            let list = lists[nextIndex]
            self.title = list.name
            
            selectedlist = list
            
            let nextController = getListController(list, index: nextIndex)
            nextController.reloadCards()
            return nextController
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
