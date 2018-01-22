//
//  CreateRideViewController.swift
//  SharedTogether
//
//  Created by Rosen Stoyanov on 17.01.18.
//  Copyright © 2018 SharedTogether Team. All rights reserved.
//

import UIKit
import FirebaseDatabase

class CreateRideViewController: BaseViewController {
    
    @IBOutlet weak var fromTextField: UITextField!
    @IBOutlet weak var destinationTextField: UITextField!
    @IBOutlet weak var freePlacesTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func createRide(_ sender: UIButton) {
        guard let from = fromTextField.text else {
            return
        }
        
        guard let destination = destinationTextField.text else {
            return
        }
        
        guard let freePlaces = freePlacesTextField.text else {
            return
        }
        
        if from.isEmpty || destination.isEmpty || freePlaces.isEmpty {
            showAlert("Error", "Please fill all fields")
            return
        }
        
        guard let freePlacesNumber = Int(freePlaces) else {
            return
        }
        
        if freePlacesNumber < 1 {
            showAlert("Error", "You must have at least 1 free place")
            return
        }
        
        let ref = Database.database().reference()
        
        let newRide = ["from": from, "destination": destination, "freePlaces": freePlaces]
        let newRideRef = ref.child(Constants.RIDES).childByAutoId()
        newRideRef.setValue(newRide)
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
