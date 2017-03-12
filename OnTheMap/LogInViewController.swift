//
//  LogInViewController.swift
//  OnTheMap
//
//  Created by 근성가이 on 2017. 3. 8..
//  Copyright © 2017년 근성가이. All rights reserved.
//

import UIKit

class LogInViewController: OnTheMapViewController {
    //MARK: - Properties
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
}

//MARK: - Actions
extension LogInViewController {
    @IBAction func logInAction(_ sender: UIButton) {
        guard let emailString = emailTextField.text, let passwordString = passwordTextField.text else {
            return
        }
        
        NetworkClient.sharedInstance().getSession(email: emailString, password: passwordString) { success, errorString in
            guard success == true else {
                print("logInAction_\(errorString)")
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

