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

class SignupViewController: BaseViewController {
    
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        phoneTextField.resignFirstResponder()
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
        
        if  email.isEmpty || password.isEmpty || confirmPassword.isEmpty || name.isEmpty || phone.isEmpty {
            showAlert("Error", "Please fill all fields")
            return;
        }
        
        if !email.isValidEmail() {
            showAlert("Error", "Invalid email")
            return
        }
        
        if !(password == confirmPassword)  {
            showAlert("Error", "Passwords dose not match")
            return
        }
        
        if let isAnonymous = Auth.auth().currentUser?.isAnonymous {
            if isAnonymous {
                let credential = EmailAuthProvider.credential(withEmail: email, password: password)
                Auth.auth().currentUser?.link(with: credential) {[weak self] (user, error) in
                    if error == nil {
                        let ref = Database.database().reference().root
                        let userDetails = [Constants.Users.EMAIL: email, Constants.Users.NAME: name, Constants.Users.PHONE: phone]
                        ref.child(Constants.Users.ROOT).child((user?.uid)!).setValue(userDetails)
                        self?.performSegue(withIdentifier: "signupToHome", sender: self)
                    } else {
                        self?.showAlert("Error", error?.localizedDescription ?? "Something went wrong")
                    }
                }
            } else {
                Auth.auth().createUser(withEmail: email, password: password, completion: { [weak self](user, error) in
                    if error == nil {
                        if let userUUId = user?.uid {
                            let ref = Database.database().reference().root
                            let userDetails = [Constants.Users.EMAIL: email, Constants.Users.NAME: name, Constants.Users.PHONE: phone]
                            ref.child(Constants.Users.ROOT).child(userUUId).setValue(userDetails)
                            self?.performSegue(withIdentifier: "signupToHome", sender: self)
                        } else {
                            print("errpr uuid not found")
                        }
                    } else {
                        self?.showAlert("Error", error?.localizedDescription ?? "Something went wrong")
                    }
                })
            }
        } else {
            Auth.auth().createUser(withEmail: email, password: password, completion: { [weak self](user, error) in
                if error == nil {
                    if let userUUId = user?.uid {
                        let ref = Database.database().reference().root
                        let userDetails = [Constants.Users.EMAIL: email, Constants.Users.NAME: name, Constants.Users.PHONE: phone]
                        ref.child(Constants.Users.ROOT).child(userUUId).setValue(userDetails)
                        self?.performSegue(withIdentifier: "signupToHome", sender: self)
                    } else {
                        print("errpr uuid not found")
                    }
                } else {
                    self?.showAlert("Error", error?.localizedDescription ?? "Something went wrong")
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
