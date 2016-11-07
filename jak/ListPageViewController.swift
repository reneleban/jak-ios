import Foundation
import CoreData
import UIKit

class ListPageViewController : UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    @IBOutlet weak var addNewCard: UIBarButtonItem!
    @IBOutlet weak var actionButton: UIBarButtonItem!
    
    let token = UserData.getToken()!
    let boardId = UserData.getSelectedBoardId()!
    
    var lists:[NSManagedObject]?
    var selectedlist:NSManagedObject?
    
    var listControllers:[ListViewController] = []
    
    var swipeEnabled = true
    
    var oldBarButtonItems:[UIBarButtonItem]?
    
    var currentIndex: Int = 0
    
    override func viewDidLoad() {
        self.dataSource = self
        self.delegate = self
        
        self.oldBarButtonItems = self.navigationItem.rightBarButtonItems
        
        loadAllLists()
    }
    
    func getListController(_ list: NSManagedObject, index: Int) -> ListViewController {
        let list_id = list.value(forKey: "list_id") as! String
        for controller in listControllers {
            if controller.getListId() == list_id {
                return controller
            }
        }
        
        let newController = self.storyboard?.instantiateViewController(withIdentifier: "listviewcontroller") as! ListViewController
        newController.list = list
        newController.index = index
        newController.useStoryboard = self.storyboard
        listControllers.append(newController)
        
        return newController
    }
    
    func getListControllers() -> [ListViewController] {
        var controllers:[ListViewController] = []
        var index = 0
        for list in lists! {
            controllers.append(getListController(list, index: index))
            index += 1
        }
        return controllers
    }
    
    func cleanUp() {
        listControllers.removeAll()
    }
    
    func loadAllLists(direction: UIPageViewControllerNavigationDirection = .forward) {
        let persistence = JakPersistence.get()
        self.lists = persistence.getLists(self.boardId)
        self.finishedLoading(direction: direction)
    }
    
    func finishedLoading(direction: UIPageViewControllerNavigationDirection) {
        DispatchQueue.main.async(execute: {
            if self.lists != nil && self.lists!.count > 0 {
                self.cleanUp()
                let list = self.lists![0]
                self.title = list.value(forKey: "name") as? String
                self.selectedlist = list
                let listController = self.getListController(list, index: 0)
                listController.reloadCards()
                self.setViewControllers([listController], direction: .forward, animated: true, completion: nil)
            } else {
                self.setViewControllers([(self.storyboard?.instantiateViewController(withIdentifier: "nolistscontroller"))!], direction: direction, animated: true, completion: nil)
            }
        })

    }
    
    @IBAction func actionButton(_ sender: AnyObject) {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "New list", style: .default, handler: { (UIAlertAction) in
            self.addListPrompt()
        }))
        
        if lists != nil && lists!.count != 0 {
            let listName = selectedlist?.value(forKey: "name") as! String
            
            actionSheet.addAction(UIAlertAction(title: "Add card with description", style: .default, handler: { (UIAlertAction) in
                self.addCardPrompt(true)
            }))
            
            actionSheet.addAction(UIAlertAction(title: "Edit mode", style: .default, handler: { (UIAlertAction) in
                self.switchEditMode()
            }))
            
            let largeview = UserData.isLargeView()
            actionSheet.addAction(UIAlertAction(title: largeview ? "Small view" : "Large view", style: .default, handler: { (UIAlertAction) in
                self.switchViewMode()
            }))
            
            actionSheet.addAction(UIAlertAction(title: "Show all available lists", style: .default, handler: { (UIAlertAction) in
                self.performSegue(withIdentifier: "availablelists", sender: self)
            }))
            
            actionSheet.addAction(UIAlertAction(title: "Delete " + listName, style: .destructive, handler: { (alert) in
                let alert = UIAlertController(title: "Warning", message: "Your cards will also be removed if you delete this list! Proceed?", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Proceed", style: .destructive, handler: { (UIAlertAction) in
                    self.deleteList()
                }))
                alert.addAction(UIAlertAction(title: "Abort", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }))
        }
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    fileprivate func switchViewMode() {
        let controller = getSelectedListController()
        if controller != nil {
            UserData.setLargeView(largeview: !UserData.isLargeView())
            
            controller!.reloadView()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let navController = segue.destination as? UINavigationController
        if let viewController = navController?.topViewController as? AvailableListsController {
            viewController.pageViewController = self
        }
    }
    
    fileprivate func switchEditMode() {
        if ReachabilityObserver.isConnected() {
            let viewController = getSelectedListController()
            if viewController != nil {
                let currentMode = viewController!.tableView.isEditing
                viewController!.tableView.setEditing(!currentMode, animated: true)
                
                if !currentMode {
                    self.navigationItem.setRightBarButtonItems([UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(finishButtonClicked))], animated: true)
                }
            }
        } else {
            ReachabilityObserver.showNoConnectionAlert(self)
        }
    }
    
    func selectList(_ list: NSManagedObject, index: Int) {
        self.selectedlist = list
        let listController = getSelectedListController()!
        listController.reloadCards()
        
        currentIndex = index
        self.title = list.value(forKey: "name") as? String
        
        self.setViewControllers([listController], direction: .reverse, animated: true, completion: nil)
    }
    
    func finishButtonClicked() {
        self.navigationItem.setRightBarButtonItems(self.oldBarButtonItems, animated: true)
        getSelectedListController()!.tableView.setEditing(false, animated: true)
    }
    
    fileprivate func getSelectedListController() -> ListViewController? {
        if selectedlist != nil {
            return getListController(selectedlist!, index: 0)
        }
        
        return nil
    }
    
    @IBAction func addNewCard(_ sender: AnyObject) {
        if lists!.count == 0 {
            addListPrompt()
        } else {
            addCardPrompt()
        }
    }
    
    func reloadCards() {
        if selectedlist != nil {
            let currentController = getListController(selectedlist!, index: 0)
            
            DispatchQueue.main.async(execute: {
                currentController.reloadCards(true)
            })
        }
    }
    
    func addCardPrompt(_ withDescription: Bool = false) {
        if ReachabilityObserver.isConnected() {
            var titleTextField: UITextField?
            var descriptionTextField: UITextField?
            
            let listPrompt = UIAlertController(title: nil, message: "Create new card", preferredStyle: .alert)
            listPrompt.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
            listPrompt.addAction(UIAlertAction(title: "Add", style: .default, handler: { (action) -> Void in
                var desc = "";
                if descriptionTextField != nil {
                    desc = descriptionTextField!.text!
                }
                
                self.addCard(titleTextField!.text!, desc: desc)
            }))
            
            listPrompt.addTextField(configurationHandler: {(textField: UITextField!) in
                textField.placeholder = "Card name ..."
                titleTextField = textField
            })
            
            if withDescription {
                listPrompt.addTextField(configurationHandler: { (textField: UITextField!) in
                    textField.placeholder = "Description ..."
                    descriptionTextField = textField
                })
            }
            
            self.present(listPrompt, animated: true, completion: nil)
        } else {
            ReachabilityObserver.showNoConnectionAlert(self)
        }
    }
    
    func addCard(_ title: String, desc: String) {
        JakCard.addCard(title, description: desc, list_id: selectedlist?.value(forKey: "list_id") as! String, token: token) { (response) in
            let dict = response.object as! NSDictionary
            let card_id = dict.value(forKey: "card_id") as! String
            let owner = dict.value(forKey: "owner") as! String
            let list_id = dict.value(forKey: "list_id") as! String
            
            DispatchQueue.main.async(execute: {
                let card = JakPersistence.get().newCard(title: title, desc: desc, card_id: card_id, owner: owner, list_id: list_id)
                if card != nil {
                    self.reloadCards()
                }
            })
        }
    }
    
    func deleteList() {
        if selectedlist != nil {
            let list_id = selectedlist?.value(forKey: "list_id") as! String
            let board_id = selectedlist?.value(forKey: "board_id") as! String
            JakCard.deleteCards(list_id, token: token, handler: { (response) in
                if response.statusCode == 200 {
                    JakList.deleteList(list_id, token: self.token, handler: { (response) in
                        JakPersistence.get().deleteList(list_id: list_id, board_id: board_id)
                        DispatchQueue.main.async(execute: {
                            self.currentIndex = 0
                            self.loadAllLists(direction: .reverse)
                        })
                    })
                }
            })
        }
    }
    
    func addListPrompt() {
        if ReachabilityObserver.isConnected() {
            var inputTextField: UITextField?
            
            let listPrompt = UIAlertController(title: nil, message: "Enter a list name", preferredStyle: .alert)
            listPrompt.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
            listPrompt.addAction(UIAlertAction(title: "Add", style: .default, handler: { (action) -> Void in
                self.addList(inputTextField!.text!)
            }))
            
            listPrompt.addTextField(configurationHandler: {(textField: UITextField!) in
                textField.placeholder = "List name ..."
                inputTextField = textField
            })
            
            self.present(listPrompt, animated: true, completion: nil)
        } else {
            ReachabilityObserver.showNoConnectionAlert(self)
        }
    }
    
    func addList(_ name: String) {
        JakList.addList(name, board_id: boardId, token: token) { (response) in
            if let list = response.object as? NSDictionary {
                let id = list.value(forKey: "list_id") as! String
                let board_id = list.value(forKey: "board_id") as! String
                let owner = list.value(forKey: "owner") as! String
                let list = JakPersistence.get().newList(name: name, list_id: id, board_id: board_id, owner: owner)
                self.loadAllLists()
                
                let vc = self.getListController(list!, index: self.lists!.count-1)
                DispatchQueue.main.async(execute: {
                    self.currentIndex = self.lists!.count-1
                    self.setViewControllers([vc], direction: .forward, animated: true, completion: nil)
                    self.title = list?.value(forKey: "name") as? String
                })
            }
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if !completed {
            return
        }
        
        let lvc = pageViewController.viewControllers![0] as! ListViewController
        self.selectedlist = lvc.getList()
        let name = lvc.getList().value(forKey: "name") as! String
        self.title = name
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if let listController = viewController as? ListViewController {
            let index = listController.getIndex()
            if index == 0 {
                return nil
            }
            
            let prevIndex = index-1
            let list = lists![prevIndex]
            
            let prevController = getListController(list, index: prevIndex)
            prevController.reloadCards()
            
            currentIndex = index
            
            return prevController
        }
        
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if let listController = viewController as? ListViewController {
            let index = listController.getIndex()
            if index == lists!.count - 1 {
                return nil
            }
            
            let nextIndex = index+1
            let list = lists![nextIndex]
            
            let nextController = getListController(list, index: nextIndex)
            nextController.reloadCards()
            
            currentIndex = index
            
            return nextController
        }
        
        return nil
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        if lists != nil {
            return lists!.count
        }
        return 0
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return currentIndex
    }
}
