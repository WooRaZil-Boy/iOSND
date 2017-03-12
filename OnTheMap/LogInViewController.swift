//
//  LogInViewController.swift
//  OnTheMap
//
//  Created by 근성가이 on 2017. 3. 8..
//  Copyright © 2017년 근성가이. All rights reserved.
//

import UIKit

class LogInViewController: OnTheMapViewController, Spinner_Protocol {
    //MARK: - Properties
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
}

//MARK: - Actions
extension LogInViewController {
    @IBAction func logInAction(_ sender: UIButton) {
        guard let emailString = emailTextField.text, let passwordString = passwordTextField.text else {
            return
        }
        
        spinnerAimation(true)
        
        NetworkClient.sharedInstance().getSession(email: emailString, password: passwordString) { success, errorString in
            self.spinnerAimation(false)
            
            guard success == true else {
                print("logInAction_\(errorString)")
                
                let alertController = UIAlertController(title: "Login connection fails", message: errorString, preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default)
                alertController.addAction(okAction)
                
                performUIUpdatesOnMain {
                    self.present(alertController, animated: true)
                }
                
                
                
                return
            }

            performUIUpdatesOnMain {
                let navigationController = self.storyboard?.instantiateViewController(withIdentifier: "NavigationController") as! UINavigationController
                
                let myNavigationBar = MyNavigationBar(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 64))
                myNavigationBar.parentNavigationController = navigationController
                
                navigationController.navigationBar.isHidden = true
                navigationController.view.addSubview(myNavigationBar)
                
                self.present(navigationController, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func signUpAction(_ sender: UIButton) {        
        openURL(NetworkClient.Contrants.UdacitySignUpPath)
    }
}

//MARK: - UITextFieldDelegate
extension LogInViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
}
