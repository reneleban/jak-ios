import Foundation
import UIKit
import LocalAuthentication

class LockScreen : UIViewController {
    
    @IBAction func authenticate(_ sender: Any) {
        auth()
    }
    
    func auth() {
        let touchIdEnabled = KeychainSwift().getBool(JakKeychain.TOUCH_ID_ENABLED.rawValue)
        if touchIdEnabled == nil || !touchIdEnabled! {
            return
        }
        
        let context = LAContext()
        var error: NSError?
        
        let reason = "Authenticate with Touch ID to unlock JAK ..."
        
        if context.canEvaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason, reply: { (success, error) in
                if success {
                    self.dismiss(animated: true, completion: nil)
                } else {
                    JakKeychainHelper.deleteAllKeychainProperties()
                    self.dismiss(animated: false, completion: nil)
                    AppDelegate.boardViewController?.dismiss(animated: true, completion: nil)
                }
            })
        }
    }
}
