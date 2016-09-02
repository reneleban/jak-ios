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
                
                if context.canEvaluatePolicy(LAPolicy.DeviceOwnerAuthenticationWithBiometrics, error: &error) {
                    context.evaluatePolicy(.DeviceOwnerAuthenticationWithBiometrics, localizedReason: reason, reply: { (success: Bool, error: NSError?) in
                        if success {
                            self.validateToken(token!)
                        } else {
                            
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
    
    private func validateToken(token: String) {
        JakLogin.validate(token, handler: { (response: JakResponse) in
            let statusCode = response.statusCode
            if statusCode == 200 {
                UserData.token = token
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.showBoard()
                })
            } else {
                dispatch_async(dispatch_get_main_queue(), {
                    let alert = UIAlertController(title: "Token invalid", message: "Your token is invalid. Please perform a fresh login!", preferredStyle: .Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                    let keychain = KeychainSwift()
                    keychain.delete("service-token")
                })
            }
        })
    }
    
    @IBAction func touchIdToggled(sender: AnyObject) {
        let touchId = sender as! UISwitch
        if touchId.on {
            let context = LAContext()
            let reasonString = "Identify yourself please ..."
            var error: NSError?
            
            if context.canEvaluatePolicy(LAPolicy.DeviceOwnerAuthenticationWithBiometrics, error: &error) {
                context.evaluatePolicy(.DeviceOwnerAuthenticationWithBiometrics, localizedReason: reasonString, reply: { (success: Bool, error: NSError?) in
                    if success {
                        let keychain = KeychainSwift()
                        keychain.set(true, forKey: "touchid-enabled")
                    } else {
                        print("\(error)")
                        
                        dispatch_async(dispatch_get_main_queue(), {
                            touchId.setOn(false, animated: true)
                        })
                    }
                })
            } else {
                touchId.setOn(false, animated: true)
                let alert = UIAlertController(title: "TouchID not available", message: "Either your TouchID sensor is disabled, or your device does not support TouchID.", preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func actionButtonPressed(sender: AnyObject) {
        self.performSegueWithIdentifier("register", sender: self)
    }
    
    @IBAction func userNameChanged(sender: AnyObject) {
    }
    
    @IBAction func loginButtonPressed(sender: AnyObject) {
        performLogin()
    }
    
    @IBOutlet weak var loginButtonPressed: UIButton!
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let navController = segue.destinationViewController as? UINavigationController
        if let viewController = navController?.topViewController as? RegisterController {
            viewController.loginController = self
        }
    }
    
    internal func setCredentials(username: String, password: String) {
        self.emailAddress.text = username
        self.password.text = password
    }
    
    private func showBoard() {
        self.performSegueWithIdentifier("home", sender: self)
    }
    
    private func performLogin() {
        JakLogin.login(self.emailAddress.text!, password: self.password.text!, handler: { (response: JakResponse) in
            let statusCode = response.statusCode
            dispatch_async(dispatch_get_main_queue(), {
                if statusCode != 200 {
                    let alert:UIAlertController = UIAlertController(title: "Error logging in", message: "Your credentials were incorrect. Please try again!", preferredStyle: .Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
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
    
    private func storeTokenInKeychain(token: String) {
        let keychain = KeychainSwift()
        
        if keychain.set(token, forKey: "service-token") {
            print("Token stored in keychain")
        } else {
            print("Token could not be stored in keychain")
        }
    }
}