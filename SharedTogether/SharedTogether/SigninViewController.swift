//
//  SigninViewController.swift
//  SharedTogether
//
//  Created by Rosen Stoyanov on 8.01.18.
//  Copyright © 2018 SharedTogether Team. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseMessaging

class SigninViewController: BaseViewController {

    fileprivate static let defaultTopConstraintValue: CGFloat = 90.0
    fileprivate static let keyboardVisibleTopConstraintValue: CGFloat = 16.0
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var loginButton: UIButton!
    
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    
    // MARK: - View Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.loginButton.layer.cornerRadius = 3.0
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: Notification.Name.UIKeyboardWillHide, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Actions
    
    @IBAction func cancel(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
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
        
        Auth.auth().createUser(withEmail: email, password: password, completion: { [weak self](user, error) in
            if error == nil {
                if let uuid = user?.uid {
                    let name = "Kristiana"
                    let phone = "888888888"
                    let ref = Database.database().reference().root
                    let userDetails = [Constants.Users.EMAIL: email, Constants.Users.NAME: name, Constants.Users.PHONE: phone]
                    
                    let token = Messaging.messaging().fcmToken ?? ""
                    let user =
                        User(id: uuid, email: email, name: name, phone: phone, notificationsToken: token, joinedRides: [String: Bool]())
                    Defaults.setLoggedUser(user: user)
                    
                    ref.child(Constants.Users.ROOT).child(uuid).setValue(userDetails)
                    
                } else {
                    print("errpr uuid not found")
                }
            } else {
                self?.showAlert("Error", error?.localizedDescription ?? "Something went wrong")
            }
        })
        
//        Auth.auth().signIn(withEmail: email, password: password) { [weak self] (user, error) in
//            if let error = error {
//                self?.showAlert("Error", error.localizedDescription)
//                return
//            }
//
//            if let wUser = user {
//
//                Utils.getUserDetails(uuid: wUser.uid, callBack: { user in
//
//                    Defaults.setLoggedUser(user: user)
//
//                    if let token = Messaging.messaging().fcmToken {
//                        Database.database().reference()
//                            .child(Constants.Users.ROOT)
//                            .child(wUser.uid)
//                            .updateChildValues([Constants.Users.NOTIFICATIONS_TOKEN: token], withCompletionBlock: {(error, dbReference) in
//                                if error == nil {
//                                    if var user = Defaults.getLoggedUser() {
//                                        user.notificationsToken = token
//                                        Defaults.setLoggedUser(user: user)
//                                        self?.dismiss(animated: true, completion: nil)
//                                        self?.presentCreateRideController()
//                                    }
//                                }
//                            })
//                    } else {
//                        self?.dismiss(animated: true, completion: nil)
//                    }
//                })
//    }
//        }
    
    }

    // MARK: - Notifications
    
    @objc func keyboardWillShow(_ notification: NSNotification) {
        let info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        UIView.animate(withDuration: 0.25, animations: { [weak self] () -> Void in
            if self?.topConstraint.constant == SigninViewController.defaultTopConstraintValue {
                let height = keyboardFrame.size.height
                let insets = UIEdgeInsetsMake(0, 0, height, 0)
                self?.scrollView.contentInset = insets
                self?.scrollView.scrollIndicatorInsets = insets
                self?.topConstraint.constant -= height/2
            }
        })
        
    }
    
    @objc func keyboardWillHide(_ notification: NSNotification) {
        let info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let height = keyboardFrame.size.height
        
        UIView.animate(withDuration: 0.25, animations: { [weak self] () -> Void in
            if (self?.topConstraint.constant)! <= SigninViewController.defaultTopConstraintValue {
            self?.scrollView.contentInset = .zero
            self?.scrollView.scrollIndicatorInsets = .zero
            self?.topConstraint.constant += height/2
            }
        })
    }
    
    fileprivate func presentCreateRideController() {
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let createRideViewController: UIViewController = storyboard.instantiateViewController(withIdentifier: "CreateRideNavigationController") as UIViewController
        self.present(createRideViewController, animated: true, completion: nil)
    }
}
