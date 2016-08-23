import Foundation
import UIKit

class LoginController : UIViewController {
    
    @IBOutlet weak var actionButton: UIBarButtonItem!
    @IBOutlet weak var emailAddress: UITextField!
    @IBOutlet weak var password: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func actionButtonPressed(sender: AnyObject) {
        self.performSegueWithIdentifier("register", sender: self)
    }
    
    @IBAction func userNameChanged(sender: AnyObject) {
    }
    
    @IBAction func loginButtonPressed(sender: AnyObject) {
        login()
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
    
    private func login() {
        let jsonConn = JsonConnection(url: Services.LOGIN.rawValue, httpMethod: "GET")
        jsonConn.basicAuth(self.emailAddress.text!, password: self.password.text!)
        jsonConn.send({
            (object, statusCode) -> Void in
            
            dispatch_async(dispatch_get_main_queue(), {
                if statusCode != 200 {
                    let alert:UIAlertController = UIAlertController(title: "Error logging in", message: "Your credentials were incorrect. Please try again!", preferredStyle: .Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                } else {
                    self.password.text = ""
                    let token = (object as! NSDictionary)["token"] as! String
                    print("Received token for \(self.emailAddress.text!): \(token)")
                    UserData.token = token
                    self.performSegueWithIdentifier("home", sender: self)
                }
            })
        })
    }
}