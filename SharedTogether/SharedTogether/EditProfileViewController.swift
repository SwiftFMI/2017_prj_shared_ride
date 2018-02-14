//
//  EditProfileViewController.swift
//  SharedTogether
//
//  Created by Rosen Stoyanov on 13.02.18.
//  Copyright © 2018 SharedTogether Team. All rights reserved.
//

import UIKit
import FirebaseMessaging

class EditProfileViewController: BaseViewController {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var firebaseTokenLabel: UILabel!
    
    var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        user = Defaults.getLoggedUser()
        
        if let user = user {
            nameTextField.text = user.name
            phoneTextField.text = user.phone
        }
        
        firebaseTokenLabel.text = Messaging.messaging().fcmToken ?? "Token not initialized"

        // Do any additional setup after loading the view.
    }

    @IBAction func onClearChangesTap(_ sender: UIButton) {
        if let user = user {
            nameTextField.text = user.name
            phoneTextField.text = user.phone
        }
        
        firebaseTokenLabel.text = Messaging.messaging().fcmToken ?? "Token not initialized"
    }
    
    @IBAction func onSaveTap(_ sender: UIButton) {
        guard let name = nameTextField.text else { return }
        guard let phone = phoneTextField.text else { return }
        
        if name.isEmpty || phone.isEmpty {
            showAlert("Error", "Please fill in all fields")
            return
        }
        
        //TODO handle server and user defaults updates
        
    }
}
