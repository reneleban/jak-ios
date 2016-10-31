import Foundation
import UIKit
import CoreData

class HomeTableViewController: UITableViewController {
    
    var boards = [NSManagedObject]()
    
    let token = UserData.getToken()!
    
    @IBOutlet weak var actionsButton: UIBarButtonItem!
    @IBOutlet var boardTableView: UITableView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadBoards(true)
        
        self.refreshControl?.addTarget(self, action: #selector(HomeTableViewController.refresh(sender:)), for: .valueChanged)
    }
    
    func refresh(sender:AnyObject) {
        if ReachabilityObserver.isConnected() {
            JakPersistence.get().cleanupBoards()
            Prefetcher.get().prefetchBoards {
                self.loadBoards(false)
            }
        } else {
            self.refreshControl?.endRefreshing()
        }
    }
    
    @IBAction func actions(_ sender: AnyObject) {
        let actionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { (alert: UIAlertAction) in
            self.settings()
        }
        
        let logoutAction = UIAlertAction(title: "Logout", style: .destructive) { (alert: UIAlertAction) in
            self.logout()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        actionMenu.addAction(settingsAction)
        actionMenu.addAction(logoutAction)
        actionMenu.addAction(cancelAction)
        
        self.present(actionMenu, animated: true, completion: nil)
    }
    
    @IBAction func addBoard(_ sender: AnyObject) {
        if ReachabilityObserver.isConnected() {
            var inputTextField: UITextField?
            
            let boardPrompt = UIAlertController(title: nil, message: "Enter a board name", preferredStyle: .alert)
            boardPrompt.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
            boardPrompt.addAction(UIAlertAction(title: "Add", style: .default, handler: { (action) -> Void in
                print("Adding board \(inputTextField?.text)")
                self.newBoard(inputTextField!.text!)
            }))
            
            boardPrompt.addTextField(configurationHandler: {(textField: UITextField!) in
                textField.placeholder = "Board name ..."
                inputTextField = textField
            })
            
            self.present(boardPrompt, animated: true, completion: nil)
        } else {
            ReachabilityObserver.showNoConnectionAlert(self)
        }
    }
    
    fileprivate func checkDefaultBoard(_ defaultBoard: Bool) {
        if !defaultBoard { return }
        
        DispatchQueue.main.async(execute: {
            let keychain = KeychainSwift()
            let defaultBoard = keychain.get(JakKeychain.DEFAULT_BOARD.rawValue)
            if defaultBoard != nil {
                let board_id = defaultBoard!
                
                var i = 0
                for board in self.boards {
                    let boardId = board.value(forKey: "board_id") as! String
                    
                    if boardId == board_id {
                        self.tableView(self.tableView, didSelectRowAt: IndexPath(row: i, section: 0))
                    }
                    i+=1
                }
            }
        })
    }
    
    fileprivate func settings() {
        self.performSegue(withIdentifier: "settingssegue", sender: self)
    }
    
    func logout() {
        let alert = UIAlertController(title: "Warning", message: "While not having an active internet connection you can't login again without an active connection.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Logout", style: .destructive, handler: { (action) in
            let keychain = KeychainSwift()
            keychain.delete(JakKeychain.SERVICE_TOKEN.rawValue)
            keychain.delete(JakKeychain.TOUCH_ID_ENABLED.rawValue)
            self.dismiss(animated: true, completion: nil)
        }))
        
        alert.addAction(UIAlertAction(title: "Abort", style: .default, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    fileprivate func newBoard(_ title: String) {
        JakBoard.addBoard(title, token: token, handler: { (response: JakResponse) in
            if let board = response.object as? NSDictionary {
                let id = board["board_id"] as! String
                let _ = JakPersistence.get().newBoard(name: title, board_id: id)
                self.loadBoards(false)
            }
        })
    }
    
    fileprivate func loadBoards(_ defaultBoard: Bool) {
        DispatchQueue.main.async(execute: {
            let persistence = JakPersistence.get()
            self.boards = persistence.getBoards()!
            self.checkDefaultBoard(defaultBoard)
            self.refreshControl?.endRefreshing()
            self.tableView.reloadData()
        })
    }
    
    fileprivate func noBoards() {
        DispatchQueue.main.async(execute: {
            let alert = UIAlertController(title: "No boards available", message: "You currently have no boards. Please add a new one!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        })
    }
    
    fileprivate func reload() {
        boards = []
        loadBoards(false)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let plainCell = tableView.cellForRow(at: indexPath)
        if plainCell != nil {
            let cell = plainCell as! BoardTableCell
            //let name = cell.textLabel?.text
            let board_id = cell.board_id
           
            UserData.setSelectedBoardId(board_id: board_id!)
            self.performSegue(withIdentifier: "list", sender: nil)
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete && ReachabilityObserver.isConnected() {
            let board = boards[(indexPath as NSIndexPath).row]
            let deleteAlert = UIAlertController(title: "Warning", message: "This will delete your board \(board.value(forKey: "name") as! String) including its lists and cards.", preferredStyle: .alert)
            
            deleteAlert.addAction(UIAlertAction(title: "Proceed", style: .destructive, handler: { (action) -> Void in
                let board_id = board.value(forKey: "board_id") as! String
                var list_ids:[String] = []
                
                JakList.loadLists(board_id, token: self.token, handler: { (response) in
                    if response.statusCode == 200 {
                        if let lists = response.object as? [[String:Any]] {
                            for list in lists {
                                let list_id = list["list_id"] as! String
                                list_ids.append(list_id)
                                
                                JakList.deleteList(list_id, token: self.token, handler: { (response) in })
                                JakCard.deleteCards(list_id, token: self.token, handler: { (response) in })
                            }
                            
                            JakBoard.deleteBoard(board_id, token: self.token, handler: { (response) in
                                if response.statusCode == 200 {
                                    DispatchQueue.main.async(execute: {
                                        JakPersistence.get().deleteBoard(board_id: board_id)
                                        
                                        self.boards.remove(at: (indexPath as NSIndexPath).row)
                                        tableView.deleteRows(at: [indexPath], with: .automatic)
                                    })
                                }
                            })
                        }
                    }

                })
            }))
            
            deleteAlert.addAction(UIAlertAction(title: "Abort", style: .default, handler: nil))
            
            self.present(deleteAlert, animated: true, completion: nil)
        } else {
            ReachabilityObserver.showNoConnectionAlert(self)
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return boards.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let index = (indexPath as NSIndexPath).row
        let cell = tableView.dequeueReusableCell(withIdentifier: "boardcell") as! BoardTableCell
        
        let board_id = boards[index].value(forKey: "board_id") as? String
        let name = boards[index].value(forKey: "name") as? String
        
        cell.textLabel?.text = name
        cell.textLabel?.textColor = UIColor.white
        cell.board_id = board_id
        
        return cell
    }
}
