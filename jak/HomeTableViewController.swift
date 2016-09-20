import Foundation
import UIKit

class HomeTableViewController: UITableViewController {
    
    var boards:[Board] = []
    
    let token = UserData.token!
    
    @IBOutlet weak var actionsButton: UIBarButtonItem!
    @IBOutlet var boardTableView: UITableView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadBoards()
    }
    
    @IBAction func actions(_ sender: AnyObject) {
        let actionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let logoutAction = UIAlertAction(title: "Logout", style: .default) { (alert: UIAlertAction) in
            self.logout()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        actionMenu.addAction(logoutAction)
        actionMenu.addAction(cancelAction)
        
        self.present(actionMenu, animated: true, completion: nil)
    }
    
    @IBAction func addBoard(_ sender: AnyObject) {
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
    }
    
    fileprivate func logout() {
        let keychain = KeychainSwift()
        keychain.delete("service-token")
        keychain.delete("touchid-enabled")
        self.dismiss(animated: true, completion: nil)
    }
    
    fileprivate func newBoard(_ title: String) {
        JakBoard.addBoard(title, token: token, handler: { (response: JakResponse) in
            if response.statusCode == 200 {
                self.reload()
            }
        })
    }
    
    fileprivate func loadBoards() {
        JakBoard.loadBoards(token, handler: { (response: JakResponse) in
            if let boards = response.object as? [[String:Any]] {
                if boards.count == 0 {
                    self.noBoards()
                }
                
                for board in boards {
                    var boardName = board["name"] as! String
                    boardName = boardName.removingPercentEncoding!
                    let b = Board(name: boardName, board_id: board["board_id"] as! String)
                    self.boards.append(b)
                }
                
                DispatchQueue.main.async(execute: {
                    self.boardTableView.reloadData()
                })
            } else {
                self.noBoards()
            }
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
        loadBoards()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! BoardTableCell
        let name = cell.textLabel?.text
        let board_id = cell.board_id
        let board = Board(name: name!, board_id: board_id!)
        UserData.selectedBoard = board
        
        self.performSegue(withIdentifier: "list", sender: nil)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let board = boards[(indexPath as NSIndexPath).row]
            let deleteAlert = UIAlertController(title: "Warning", message: "This will delete your board \(board.name) including its lists and cards.", preferredStyle: .alert)
            
            deleteAlert.addAction(UIAlertAction(title: "Proceed", style: .destructive, handler: { (action) -> Void in
                let board_id = board.board_id
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
                            
                            JakBoard.deleteBoard(board.board_id, token: self.token, handler: { (response) in
                                if response.statusCode == 200 {
                                    DispatchQueue.main.async(execute: {
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
        
        let board_id = boards[index].board_id
        let name = boards[index].name
        
        cell.textLabel?.text = name
        cell.textLabel?.textColor = UIColor.white
        cell.board_id = board_id
        
        return cell
    }
}
