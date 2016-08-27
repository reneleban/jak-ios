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
    
    @IBAction func actions(sender: AnyObject) {
        let actionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        let logoutAction = UIAlertAction(title: "Logout", style: .Default) { (alert: UIAlertAction) in
            self.logout()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        
        actionMenu.addAction(logoutAction)
        actionMenu.addAction(cancelAction)
        
        self.presentViewController(actionMenu, animated: true, completion: nil)
    }
    
    @IBAction func addBoard(sender: AnyObject) {
        var inputTextField: UITextField?
        
        let boardPrompt = UIAlertController(title: nil, message: "Enter a board name", preferredStyle: .Alert)
        boardPrompt.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: nil))
        boardPrompt.addAction(UIAlertAction(title: "Add", style: .Default, handler: { (action) -> Void in
            print("Adding board \(inputTextField?.text)")
            self.newBoard(inputTextField!.text!)
        }))
        
        boardPrompt.addTextFieldWithConfigurationHandler({(textField: UITextField!) in
            textField.placeholder = "Board name ..."
            inputTextField = textField
        })
        
        self.presentViewController(boardPrompt, animated: true, completion: nil)
    }
    
    private func logout() {
        let keychain = KeychainSwift()
        keychain.delete("service-token")
        keychain.delete("touchid-enabled")
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    private func newBoard(title: String) {
        let jsonConn = JsonConnection(url: Services.BOARD.rawValue + "board/" + token, httpMethod: "PUT")
        jsonConn.addParameter("name", value: title)
        jsonConn.send { (object, statusCode) in
            if statusCode == 200 {
                self.reload()
            }
        }
    }
    
    private func loadBoards() {
        let jsonConn = JsonConnection(url: Services.BOARD.rawValue + "board/" + token, httpMethod: "GET")
        jsonConn.send { (object, statusCode) in
            if let boards = object as? NSArray {
                if boards.count == 0 {
                    self.noBoards()
                }
                
                for board in boards {
                    var boardName = board["name"] as! String
                    boardName = boardName.stringByRemovingPercentEncoding!
                    
                    print("\(boardName)")
                    let b = Board(name: boardName, board_id: board["board_id"] as! String)
                    self.boards.append(b)
                }
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.boardTableView.reloadData()
                })
            } else {
                self.noBoards()
            }
        }
    }
    
    private func noBoards() {
        dispatch_async(dispatch_get_main_queue(), {
            let alert = UIAlertController(title: "No boards available", message: "You currently have no boards. Please add a new one!", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        })
    }
    
    private func reload() {
        boards = []
        loadBoards()
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! BoardTableCell
        let name = cell.textLabel?.text
        let board_id = cell.board_id
        let board = Board(name: name!, board_id: board_id!)
        UserData.selectedBoard = board
        
        self.performSegueWithIdentifier("list", sender: nil)
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let board = boards[indexPath.row]
            let jsonConn = JsonConnection(url: Services.BOARD.rawValue + "board/" + token + "/" + board.board_id, httpMethod: "DELETE")
            jsonConn.send { (object, statusCode) in
                if statusCode == 200 {
                    dispatch_async(dispatch_get_main_queue(), {
                        self.boards.removeAtIndex(indexPath.row)
                        tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
                    })
                }
            }
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return boards.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let index = indexPath.row
        let cell = tableView.dequeueReusableCellWithIdentifier("boardcell") as! BoardTableCell
        
        let board_id = boards[index].board_id
        let name = boards[index].name
        
        cell.textLabel?.text = name
        cell.textLabel?.textColor = UIColor.whiteColor()
        cell.board_id = board_id
        
        return cell
    }
}