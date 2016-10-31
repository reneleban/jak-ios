import Foundation
import UIKit
import LocalAuthentication

class LoginController : UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var actionButton: UIBarButtonItem!
    @IBOutlet weak var emailAddress: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var touchId: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailAddress.delegate = self
        password.delegate = self
        
        let keychain = KeychainSwift()
        let token = keychain.get(JakKeychain.SERVICE_TOKEN.rawValue)
        if token != nil {
            let touchIdEnabled = keychain.getBool(JakKeychain.TOUCH_ID_ENABLED.rawValue)
            if touchIdEnabled != nil && touchIdEnabled! {
                let context = LAContext()
                let reason = "Touch ID is enabled"
                var error: NSError?
                
                if context.canEvaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, error: &error) {
                    context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason, reply: { (success, error) in
                        if success {
                            self.validateToken(token!)
                        } else {
                            let alert = UIAlertController(title: "Error", message: "You could not be verified with Touch ID. Your token has been invalidated!", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                            self.present(alert, animated: true)
                            keychain.delete(JakKeychain.TOUCH_ID_ENABLED.rawValue)
                            keychain.delete(JakKeychain.SERVICE_TOKEN.rawValue)
                        }
                    })
                }
            } else {
                self.validateToken(token!)
            }
        } else {
            print("No token was found")
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailAddress {
            password.becomeFirstResponder()
        } else if textField == password {
            performLogin()
        }
        return true
    }
    
    fileprivate func validateToken(_ token: String) {
        if ReachabilityObserver.isConnected() {
            JakLogin.validate(token, handler: { (response: JakResponse) in
                let statusCode = response.statusCode
                if statusCode == 200 {
                    UserData.setToken(token)
                    self.runPrefetcher()
                } else {
                    DispatchQueue.main.async(execute: {
                        let alert = UIAlertController(title: "Token invalid", message: "Your token is invalid. Please perform a fresh login!", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                        let keychain = KeychainSwift()
                        keychain.delete(JakKeychain.SERVICE_TOKEN.rawValue)
                    })
                }
            })
        } else {
            // Assuming we have not active internet connection, but have a token for this user ...
            UserData.setToken(token)
            self.runPrefetcher()
        }
    }
    
    @IBAction func touchIdToggled(_ sender: AnyObject) {
        let touchId = sender as! UISwitch
        if touchId.isOn {
            let context = LAContext()
            let reasonString = "Activating Touch ID ..."
            var error: NSError?
            
            if context.canEvaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, error: &error) {
                context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reasonString, reply: { (success, error) -> Void in
                    if success {
                        let keychain = KeychainSwift()
                        keychain.set(true, forKey: JakKeychain.TOUCH_ID_ENABLED.rawValue)
                    } else {
                        print("\(error)")
                        
                        DispatchQueue.main.async(execute: {
                            touchId.setOn(false, animated: true)
                        })
                    }
                })
            } else {
                touchId.setOn(false, animated: true)
                let alert = UIAlertController(title: "Touch ID not available", message: "Either your Touch ID sensor is disabled, or your device does not support Touch ID.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        } else {
            let keychain = KeychainSwift()
            keychain.delete(JakKeychain.TOUCH_ID_ENABLED.rawValue)
        }
    }
    
    @IBAction func actionButtonPressed(_ sender: AnyObject) {
        self.performSegue(withIdentifier: "register", sender: self)
    }
    
    @IBAction func userNameChanged(_ sender: AnyObject) {
    }
    
    @IBAction func loginButtonPressed(_ sender: AnyObject) {
        performLogin()
    }
    
    @IBOutlet weak var loginButtonPressed: UIButton!
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let navController = segue.destination as? UINavigationController
        if let viewController = navController?.topViewController as? RegisterController {
            viewController.loginController = self
        }
    }
    
    internal func setCredentials(_ username: String, password: String) {
        self.emailAddress.text = username
        self.password.text = password
    }
    
    fileprivate func runPrefetcher() {
        let p = Prefetcher.get()
        p.prefetch(self)
    }
    
    func showBoardViewController() {
        DispatchQueue.main.async(execute: {
            print("Show view controller called")
            self.performSegue(withIdentifier: "home", sender: self)
        })
    }
    
    fileprivate func performLogin() {
        JakLogin.login(self.emailAddress.text!, password: self.password.text!, handler: { (response: JakResponse) in
            let statusCode = response.statusCode
            DispatchQueue.main.async(execute: {
                if statusCode != 200 {
                    let alert:UIAlertController = UIAlertController(title: "Error logging in", message: "Your credentials were incorrect. Please try again!", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                } else {
                    self.password.text = ""
                    let token = (response.object as! NSDictionary)["token"] as! String
                    print("Received token for \(self.emailAddress.text!): \(token)")
                    UserData.setToken(token)
                    self.storeTokenInKeychain(token)
                    self.runPrefetcher()
                }
            })
        })
    }
    
    fileprivate func storeTokenInKeychain(_ token: String) {
        let keychain = KeychainSwift()
        
        if keychain.set(token, forKey: JakKeychain.SERVICE_TOKEN.rawValue) {
            print("Token stored in keychain")
        } else {
            print("Token could not be stored in keychain")
        }
    }
}
