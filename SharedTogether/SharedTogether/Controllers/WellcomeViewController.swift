//
//  ViewController.swift
//  SharedTogether
//
//  Created by Rosen Stoyanov on 8.01.18.
//  Copyright © 2018 SharedTogether Team. All rights reserved.
//

import UIKit
import FirebaseAuth

//silent sign in
//https://github.com/firebase/firebase-simple-login/blob/master/docs/v1/providers/anonymous.md
class WellcomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        if Auth.auth().currentUser != nil {
            performSegue(withIdentifier: "wellcomeToHome", sender: self)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func unwindToWellcome(unwindSegue: UIStoryboardSegue) {
        
    }

}

