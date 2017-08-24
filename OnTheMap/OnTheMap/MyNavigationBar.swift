//
//  MyNavigationBar.swift
//  OnTheMap
//
//  Created by 근성가이 on 2017. 3. 9..
//  Copyright © 2017년 근성가이. All rights reserved.
//

import UIKit

class MyNavigationBar: UINavigationBar, Xib_Protocol {
    //MARK: - Properties
    weak var parentNavigationController: UINavigationController!
    
    //MARK: - Initialization
    override init(frame: CGRect) { //코드로 생성 시
        super.init(frame: frame)
        initialization("MyNavigationBar")
    }
    
    required init?(coder aDecoder: NSCoder) { //스토리보드에서 생성 시
        super.init(coder: aDecoder)
        initialization("MyNavigationBar")
    }
}

//MARK: - Actions
extension MyNavigationBar {
    @IBAction func logOutAction(_ sender: UIBarButtonItem) {
        NetworkClient.sharedInstance().deleteSession() { success, errorString in
            guard success == true else {
                print("logOutAction_\(errorString)")
                return
            }
            
            performUIUpdatesOnMain {
                self.parentNavigationController.dismiss(animated: true)
            }
        }
    }
    
    @IBAction func pinAction(_ sender: UIBarButtonItem) {
        NetworkClient.sharedInstance().getStudentLocation() { success, errorString, objectID in
            guard success == true else {
                print("pinAction_\(errorString)")
                return
            }
            
            if let _  = objectID {
                let alertController = UIAlertController(title: nil, message: "You Have Already Posted a Student Location. Would You Like to Overwrite Your Current Location?", preferredStyle: .alert)
                let overwriteAction = UIAlertAction(title: "Overwrite", style: .default) { _ in
                    self.presentPostingViewController()
                }
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
                alertController.addAction(overwriteAction)
                alertController.addAction(cancelAction)
                
                self.parentNavigationController.present(alertController, animated: true)
            } else {
                performUIUpdatesOnMain {
                    self.presentPostingViewController()
                }
            }
        }
    }
    
    @IBAction func refreshAction(_ sender: UIBarButtonItem) {
        NetworkClient.sharedInstance().getStudentLocations() { success, errorString in
            guard success == true else {
                print("refreshAction_\(errorString)")
                
                let alertController = UIAlertController(title: "Can't Refresh", message: errorString, preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default)
                alertController.addAction(okAction)
                self.parentNavigationController.present(alertController, animated: true)
                
                return
            }
            
            performUIUpdatesOnMain {
                let tabBarController = self.parentNavigationController.visibleViewController as! UITabBarController
                let currentViewController = tabBarController.selectedViewController as! OnTheMapViewController
                
                currentViewController.refreshAction()
            }
        }
    }
}

//MARK: - Methods
extension MyNavigationBar {
    func presentPostingViewController() {
        let postingViewController = parentNavigationController.storyboard?.instantiateViewController(withIdentifier: "PostingViewController") as! PostingViewController
        parentNavigationController.present(postingViewController, animated: true)
    }
}
