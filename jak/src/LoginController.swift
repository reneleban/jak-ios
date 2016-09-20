import Foundation
import UIKit
import LocalAuthentication

class LoginController : UIViewController {
    
    @IBOutlet weak var actionButton: UIBarButtonItem!
    @IBOutlet weak var emailAddress: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var touchId: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let keychain = KeychainSwift()
        let token = keychain.get("service-token")
        if token != nil {
            let touchIdEnabled = keychain.getBool("touchid-enabled")
            if touchIdEnabled != nil && touchIdEnabled! {
                let context = LAContext()
                let reason = "TouchID is activated. Identify yourself ..."
                var error: NSError?
                
                if context.canEvaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, error: &error) {
                    context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason, reply: { (success: Bool, error: NSError?) in
                        if success {
                            self.validateToken(token!)
                        } else {
                            
                        }
                    } as! (Bool, Error?) -> Void)
                }
            } else {
                self.validateToken(token!)
            }
        } else {
            print("No token was found")
        }
    }
    
    fileprivate func validateToken(_ token: String) {
        JakLogin.validate(token, handler: { (response: JakResponse) in
            let statusCode = response.statusCode
            if statusCode == 200 {
                UserData.token = token
                
                DispatchQueue.main.async(execute: {
                    self.showBoard()
                })
            } else {
                DispatchQueue.main.async(execute: {
                    let alert = UIAlertController(title: "Token invalid", message: "Your token is invalid. Please perform a fresh login!", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    let keychain = KeychainSwift()
                    keychain.delete("service-token")
                })
            }
        })
    }
    
    @IBAction func touchIdToggled(_ sender: AnyObject) {
        let touchId = sender as! UISwitch
        if touchId.isOn {
            let context = LAContext()
            let reasonString = "Identify yourself please ..."
            var error: NSError?
            
            if context.canEvaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, error: &error) {
                context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reasonString, reply: { (success: Bool, error: NSError?) in
                    if success {
                        let keychain = KeychainSwift()
                        keychain.set(true, forKey: "touchid-enabled")
                    } else {
                        print("\(error)")
                        
                        DispatchQueue.main.async(execute: {
                            touchId.setOn(false, animated: true)
                        })
                    }
                } as! (Bool, Error?) -> Void)
            } else {
                touchId.setOn(false, animated: true)
                let alert = UIAlertController(title: "TouchID not available", message: "Either your TouchID sensor is disabled, or your device does not support TouchID.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
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
    
    fileprivate func showBoard() {
        self.performSegue(withIdentifier: "home", sender: self)
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
                    UserData.token = token
                    self.storeTokenInKeychain(token)
                    self.showBoard()
                }
            })
        })
    }
    
    fileprivate func storeTokenInKeychain(_ token: String) {
        let keychain = KeychainSwift()
        
        if keychain.set(token, forKey: "service-token") {
            print("Token stored in keychain")
        } else {
            print("Token could not be stored in keychain")
        }
    }
}
