import Foundation
import UIKit

class SettingsViewController : UIViewController {
    
    @IBOutlet weak var defaultBoardButton: UIButton!
    
    private var boards:[[String:String]]? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        JakBoard.loadBoards(UserData.getToken()!) { (response) in
            if response.statusCode == 200 {
                self.boards = response.object as? [[String:String]]
                
                let keychain = KeychainSwift()
                let defaultBoard = keychain.get(JakKeychain.DEFAULT_BOARD.rawValue)
                if defaultBoard != nil {
                    let board_id = defaultBoard!
                    for b in self.boards! {
                        if b["board_id"] == board_id {
                            DispatchQueue.main.async {
                                self.defaultBoardButton.setTitle(b["name"], for: UIControlState.normal)
                            }
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func defaultBoard(_ sender: UIButton) {
        let sheet = UIAlertController(title: "Select new default board", message: nil, preferredStyle: .actionSheet)
        
        for b in boards! {
            let action = UIAlertAction(title: b["name"], style: .default, handler: { (action) in
                self.setDefaultBoard(b["board_id"])
                sender.setTitle(b["name"], for: UIControlState.normal)
            })
            sheet.addAction(action)
        }
        
        let action = UIAlertAction(title: "Disable", style: .cancel, handler: { (action) in
            self.setDefaultBoard(nil)
            sender.setTitle("No default board set", for: UIControlState.normal)
        })
        sheet.addAction(action)
        
        self.present(sheet, animated: true, completion: nil)
    }
    
    fileprivate func setDefaultBoard(_ board_id: String?) {
        let keychain = KeychainSwift()
        if board_id != nil {
            keychain.set(board_id!, forKey: JakKeychain.DEFAULT_BOARD.rawValue)
        } else {
            keychain.delete(JakKeychain.DEFAULT_BOARD.rawValue)
        }
    }
    
    @IBAction func reset(_ sender: AnyObject) {
        JakPersistence.get().reset()
        let keychain = KeychainSwift()
        keychain.delete(JakKeychain.SERVICE_TOKEN.rawValue)
        
        let alert = UIAlertController(title: "Reset successful", message: "Your settings and user data has been wiped. You'll be logged out now!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (UIAlertAction) in
            self.dismiss(animated: true)
        }))
        self.present(alert, animated: true, completion: nil)
        
        
    }
}
