//
//  HomeViewController.swift
//  SharedTogether
//
//  Created by Rosen Stoyanov on 8.01.18.
//  Copyright © 2018 SharedTogether Team. All rights reserved.
//

import UIKit
import FirebaseAuth

class HomeViewController: UIViewController {

    @IBOutlet weak var wellcomeLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let user = Auth.auth().currentUser {
            if !user.isAnonymous {
                if let userEmail = user.email {
                    wellcomeLabel.text = userEmail
                }
            }
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func logout(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            // TODO: redirect to wellcome VC
        } catch {
            
        }
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
