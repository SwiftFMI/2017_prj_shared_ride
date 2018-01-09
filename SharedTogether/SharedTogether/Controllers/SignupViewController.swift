//
//  SignupViewController.swift
//  SharedTogether
//
//  Created by Rosen Stoyanov on 8.01.18.
//  Copyright © 2018 SharedTogether Team. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class SignupViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confiemPasswordTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func signup(_ sender: Any) {
        guard let email = emailTextField.text else {
            return
        }
        guard let password = passwordTextField.text else {
            return
        }
        guard let confirmPassword = confiemPasswordTextField.text else {
            return
        }
        guard let name = nameTextField.text else {
            return
        }
        guard let phone = phoneTextField.text else {
            return
        }
        
        //TODO: add validation
        
        if let isAnonymous = Auth.auth().currentUser?.isAnonymous {
            if isAnonymous {
                let credential = EmailAuthProvider.credential(withEmail: email, password: password)
                Auth.auth().currentUser?.link(with: credential) { (user, error) in
                    if error == nil {
                        let ref = Database.database().reference().root
                        let userDetails = ["email": email, "name": name, "phone": phone]
                        ref.child(Constants.USERS).child((user?.uid)!).setValue(userDetails)
                    } else {
                        print(error?.localizedDescription ?? "Something went wrong")
                    }
                    
                    
                }
            } else {
                Auth.auth().createUser(withEmail: email, password: password, completion: {(user, error) in
                    if error == nil {

                        if let userUUId = user?.uid {
                            let ref = Database.database().reference().root
                            let userDetails = ["email": email, "name": name, "phone": phone]
                            ref.child(Constants.USERS).child(userUUId).setValue(userDetails)
                            print("success")
                        } else {
                            print("errpr uuid not found")
                        }
                    } else {
                        print(error?.localizedDescription ?? "Something went wrong")
                    }
                })
            }
        } else {
            Auth.auth().createUser(withEmail: email, password: password, completion: {(user, error) in
                if error == nil {
                    
                    if let userUUId = user?.uid {
                        let ref = Database.database().reference().root
                        let userDetails = ["email": email, "name": name, "phone": phone]
                        ref.child(Constants.USERS).child(userUUId).setValue(userDetails)
                        print("success")
                    } else {
                        print("errpr uuid not found")
                    }
                } else {
                    print(error?.localizedDescription ?? "Something went wrong")
                }
            })
        }
    }
    
    func saveUserDetails(uuid: String, email: String, name: String, phone: String) {
        let ref = Database.database().reference().root
        let userDetails = ["email": email, "name": name, "phone": phone]
        ref.child(Constants.USERS).child(uuid).setValue(userDetails)
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
