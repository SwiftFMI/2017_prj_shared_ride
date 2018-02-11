//
//  BaseViewController.swift
//  SharedTogether
//
//  Created by Rosen Stoyanov on 15.01.18.
//  Copyright © 2018 SharedTogether Team. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {
    
    override func viewDidLoad() {
        self.hideKeyboardWhenTappedAround()
    }
    
    func showAlert(_ title: String, _ message: String){
        // create the alert
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        // add an action (button)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }

}
