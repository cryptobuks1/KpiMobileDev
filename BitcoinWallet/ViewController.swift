//
//  ViewController.swift
//  CloudStorage
//
//  Created by Lado on 12/2/19.
//  Copyright © 2019 Lado. All rights reserved.
//

import UIKit
import FirebaseAuth
import LocalAuthentication
import SkyFloatingLabelTextField

class ViewController: UIViewController, UITextFieldDelegate{

    @IBOutlet weak var emailText: SkyFloatingLabelTextField!
    
    @IBOutlet weak var passText: SkyFloatingLabelTextField!
    
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    @IBOutlet weak var actionButton: UIButton!
    
    @IBOutlet weak var cloudLabel: UILabel!
    
    @IBOutlet weak var DarkSwitch: UISwitch!
    
    @IBAction func action(_ sender: UIButton) {
        
        //check email text
        if((emailText.text?.characters.count)! < 3 || !(emailText.text?.contains("@"))!) {
            emailText.errorMessage = "Invalid email"
        }
        
        //check password
        if((passText.text?.characters.count)! < 6) {
            passText.errorMessage = "Invalid password"
        }
        
        //auth by touch id
        if emailText.text != "" {
            if segmentControl.selectedSegmentIndex == 0 {
                
                Auth.auth().fetchSignInMethods(forEmail: emailText.text!) { (signInMethods, error) in
                    if let error = error {
                        print("Error Error Error Error Error ",error)
                    } else if let signInMethods = signInMethods?.contains(EmailLinkAuthSignInMethod) {
                        print("BBBBBBBBB ", signInMethods)
                    }
                }
                
                Auth.auth().fetchProviders(forEmail: emailText.text!) { (providers, error) in
                    if let error = error {
                        print(error.localizedDescription)
                    } else if let providers = providers {
                        print("AAAAAAA ", providers)
                        
                        //touch id
                        let myContext = LAContext()
                        let myLocalizedReasonString = "Cloud Authntication"
                        
                        var authError: NSError?
                        if #available(iOS 8.0, macOS 10.12.1, *) {
                            if myContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authError) {
                                myContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: myLocalizedReasonString) { success, evaluateError in
                                    
                                    DispatchQueue.main.async {
                                        if success {
                                            // User authenticated successfully, take appropriate action
                                            print("Awesome!!... User authenticated successfully")
                                            self.performSegue(withIdentifier: "goHome", sender: self)
                                        } else {
                                            // User did not authenticate successfully, look at error and take appropriate action
                                            print("Sorry!!... User did not authenticate successfully")
                                        }
                                    }
                                }
                            } else {
                                // Could not evaluate policy; look at authError and present an appropriate message to user
                                print("Sorry!!.. Could not evaluate policy.")
                            }
                        } else {
                            // Fallback on earlier versions
                            print("Ooops!!.. This feature is not supported.")
                        }
                    }
                }
            }
        }
        
        //Login & Sign Up
        if emailText.text != "" && passText.text != "" {
            if segmentControl.selectedSegmentIndex == 0 { //Login
                Auth.auth().signIn(withEmail: emailText.text!, password: passText.text!, completion: { (user, error) in
                    if user != nil {
                        // Sign in successful
                        self.performSegue(withIdentifier: "goHome", sender: self)
                    } else {
                        if let myError = error?.localizedDescription {
                            let alertController = UIAlertController(title: "Error", message: myError, preferredStyle: UIAlertController.Style.alert)
                            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                            self.present(alertController, animated: true, completion: nil)
                            print(myError)
                        } else {
                            let alertController = UIAlertController(title: "Error", message: "Error!", preferredStyle: UIAlertController.Style.alert)
                            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                            self.present(alertController, animated: true, completion: nil)
                            print("Error!")
                        }
                    }
                })
            } else { //Sign up
                Auth.auth().createUser(withEmail: emailText.text!, password: passText.text!) { (user, error) in
                    if user != nil {
                        self.performSegue(withIdentifier: "goHome", sender: self)
                    } else {
                        if let myError = error?.localizedDescription {
                            let alertController = UIAlertController(title: "Error", message: myError, preferredStyle: UIAlertController.Style.alert)
                            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                            self.present(alertController, animated: true, completion: nil)
                            print(myError)
                        } else {
                            let alertController = UIAlertController(title: "Error", message: "Error!", preferredStyle: UIAlertController.Style.alert)
                            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                            self.present(alertController, animated: true, completion: nil)
                            print("Error!")
                        }
                    }
                }
            }
        }
    }
    
    //background color using hex
    func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //set background color and label text color
        self.view.backgroundColor = hexStringToUIColor(hex: "#041D34")
        cloudLabel.textColor = hexStringToUIColor(hex: "#76B6D7")
        //kepp a user log in, even if they close the app
        if Auth.auth().currentUser != nil {
            self.performSegue(withIdentifier: "goHome", sender: self)
        }
    }
    
    var DarkOn = Bool()
    
    @IBAction func DarkAction(_ sender: Any) {
        if DarkSwitch.isOn == true {
            self.view.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
            
            cloudLabel.textColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            
        } else {
            self.view.backgroundColor = hexStringToUIColor(hex: "#041D34")
            cloudLabel.textColor = hexStringToUIColor(hex: "#76B6D7")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //set placeholder for textfields and set colors
        emailText.placeholder = "Email"
        emailText.placeholderColor = hexStringToUIColor(hex: "#76B6D7")
        emailText.tintColor = hexStringToUIColor(hex: "#76B6D7")
        emailText.selectedTitleColor = hexStringToUIColor(hex: "#76B6D7")
        
        passText.placeholder = "Password"
        passText.placeholderColor = hexStringToUIColor(hex: "#76B6D7")
        passText.tintColor = hexStringToUIColor(hex: "#76B6D7")
        passText.selectedTitleColor = hexStringToUIColor(hex: "#76B6D7")
        
        //set broder and color for textfields
        emailText.backgroundColor = hexStringToUIColor(hex: "#1F384E")
        emailText.layer.cornerRadius = 12.0
        emailText.layer.borderWidth = 2.0
        emailText.layer.borderColor = hexStringToUIColor(hex: "#1F384E").cgColor
        emailText.textColor = hexStringToUIColor(hex: "#76B6D7")
        
        passText.backgroundColor = hexStringToUIColor(hex: "#1F384E")
        passText.layer.cornerRadius = 12.0
        passText.layer.borderWidth = 2.0
        passText.layer.borderColor = hexStringToUIColor(hex: "#1F384E").cgColor
        passText.textColor = hexStringToUIColor(hex: "#76B6D7")
        
        //clear button
        emailText.clearButtonMode = .whileEditing
        passText.clearButtonMode = .whileEditing
        
        self.emailText.delegate = self
        self.passText.delegate = self
        
        emailText.returnKeyType = UIReturnKeyType.next
        passText.returnKeyType = UIReturnKeyType.go
        
        //set background for button
        actionButton.setTitleColor(hexStringToUIColor(hex: "#68C80C"), for: .normal)
        
        //change segmentation control
        segmentControl.backgroundColor = .clear
        segmentControl.tintColor = .clear
        
        segmentControl.setTitleTextAttributes([
            NSAttributedString.Key.font : UIFont(name: "DINCondensed-Bold", size: 22),
            NSAttributedString.Key.foregroundColor: UIColor.lightGray
            ], for: .normal)
        
        segmentControl.setTitleTextAttributes([
            NSAttributedString.Key.font : UIFont(name: "DINCondensed-Bold", size: 22),
            NSAttributedString.Key.foregroundColor: UIColor.orange
            ], for: .selected)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    //rotation
    override open var shouldAutorotate: Bool {
        return false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        self.view.endEditing(true)
        return false
    }
}

