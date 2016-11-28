import Foundation
import UIKit
import CoreData
import LocalAuthentication

class SettingsViewController : UIViewController {
    
    @IBOutlet weak var defaultBoardButton: UIButton!
    @IBOutlet weak var touchIdSwitch: UISwitch!
    
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
        
        let touchIdEnabled = keychain.getBool(JakKeychain.TOUCH_ID_ENABLED.rawValue)
        touchIdSwitch.isOn = touchIdEnabled != nil ? touchIdEnabled! : false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        Prefetcher.get().resetShowBoardViewController()
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
    
    @IBAction func touchIdSwitch(_ sender: UISwitch) {
        if sender.isOn {
            touchId(true, reason: "Enabling Touch ID ...")
        } else {
            touchId(false, reason: "Disabling Touch ID ...")
        }
    }
    
    fileprivate func touchId(_ state: Bool, reason: String) {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason, reply: { (success, error) in
                if success {
                    let keychain = KeychainSwift()
                    if state {
                        keychain.set(true, forKey: JakKeychain.TOUCH_ID_ENABLED.rawValue)
                    } else {
                        keychain.delete(JakKeychain.TOUCH_ID_ENABLED.rawValue)
                    }
                } else {
                    DispatchQueue.main.async(execute: {
                        self.touchIdSwitch.setOn(!state, animated: true)
                    })
                }
            })
        }
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
        let alert = UIAlertController(title: "WARNING", message: "This will reset everything in JAK!", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Abort", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Proceed", style: .destructive, handler: { (action) in
            JakPersistence.get().reset()
            JakKeychainHelper.deleteAllKeychainProperties()
            
            let alert = UIAlertController(title: "Reset successful", message: "Your settings and user data has been wiped. You'll be logged out now!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (UIAlertAction) in
                self.dismiss(animated: true)
            }))
            self.present(alert, animated: true, completion: nil)
        }))
                
        self.present(alert, animated: true, completion: nil)
    }
}
