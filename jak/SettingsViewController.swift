import Foundation
import UIKit
import CoreData

class SettingsViewController : UIViewController {
    
    @IBOutlet weak var defaultBoardButton: UIButton!
    
    private var boards:[NSManagedObject]? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.boards = JakPersistence.get().getBoards()
        
        let keychain = KeychainSwift()
        let defaultBoard = keychain.get(JakKeychain.DEFAULT_BOARD.rawValue)
        if defaultBoard != nil {
            let board_id = defaultBoard!
            for b in self.boards! {
                let id = b.value(forKey: "board_id") as! String
                let name = b.value(forKey: "name") as! String
                if id == board_id {
                    DispatchQueue.main.async {
                        self.defaultBoardButton.setTitle(name, for: UIControlState.normal)
                    }
                }
            }
        }
    }
    
    @IBAction func logout(_ sender: Any) {
        self.logout()
    }
    
    @IBAction func defaultBoard(_ sender: UIButton) {
        if ReachabilityObserver.isConnected() {
            if boards != nil {
                let sheet = UIAlertController(title: "Select new default board", message: nil, preferredStyle: .actionSheet)
                
                for b in boards! {
                    let name = b.value(forKey: "name") as! String
                    let id = b.value(forKey: "board_id") as! String
                    let action = UIAlertAction(title: name, style: .default, handler: { (action) in
                        self.setDefaultBoard(id)
                        sender.setTitle(name, for: UIControlState.normal)
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
        } else {
            ReachabilityObserver.showNoConnectionAlert(self)
        }
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
        JakKeychainHelper.deleteAllKeychainProperties()
        
        let alert = UIAlertController(title: "Reset successful", message: "Your settings and user data has been wiped. You'll be logged out now!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (UIAlertAction) in
            self.dismiss(animated: true)
        }))
        self.present(alert, animated: true, completion: nil)
    }
}
