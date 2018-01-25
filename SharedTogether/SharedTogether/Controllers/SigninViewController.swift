//
//  SigninViewController.swift
//  SharedTogether
//
//  Created by Rosen Stoyanov on 8.01.18.
//  Copyright © 2018 SharedTogether Team. All rights reserved.
//

import UIKit
import FirebaseAuth

class SigninViewController: BaseViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func doLogin(_ sender: UIButton) {
        guard let email = emailTextField.text else {
            return
        }
        
        guard let password = passwordTextField.text else {
            return
        }
        
        if email.isEmpty || password.isEmpty {
            showAlert("Error", "Please fill all fields")
            return
        }
        
        if !email.isValidEmail() {
            showAlert("Error", "Invalid email")
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] (user, error) in
            if error == nil, let wUser = user {
                Utils.getUserDetails(uuid: wUser.uid, callBack: { user in
                    UserDefaults.standard.set(user.name, forKey: Constants.UserDefaults.USER)
                    self?.performSegue(withIdentifier: "loginToHome", sender: self)
                })
                
            } else {
                self?.showAlert("Error", error?.localizedDescription ?? "Something went wrong")
            }
        }
        
    }

}
