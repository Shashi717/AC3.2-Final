//
//  LoginViewController.swift
//  AC3.2-Final
//
//  Created by Madushani Lekam Wasam Liyanage on 2/15/17.
//  Copyright © 2017 C4Q. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    var user: FIRUser?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        
        if let email = emailTextField.text, let password = passwordTextField.text {
            
            FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user, error) in
                if let error = error {
                    print("User Signin Error \(error.localizedDescription)")
                }
                else {
                    print("Successfully signed in")
                    self.user = user
                    
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    
                    let svc = storyboard.instantiateViewController(withIdentifier: "TabBarVC")
                    self.present(svc, animated: true, completion: nil)
                    
                    
//                    dump(FIRAuth.auth()?.currentUser?.providerID)
                   // dump(user)
                }
            })
            
        }
        
    }
 
    @IBAction func registerButtonTapped(_ sender: UIButton) {
        if let email = emailTextField.text, let password = passwordTextField.text {
            
           FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user, error) in
                if let error = error {
                    print("User Creating Error \(error.localizedDescription)")
                }
                else {
                    print("Successfully created user!")
            }
            })
            
        }
        
    }
    

}
