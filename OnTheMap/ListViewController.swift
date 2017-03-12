//
//  ListViewController.swift
//  OnTheMap
//
//  Created by 근성가이 on 2017. 3. 9..
//  Copyright © 2017년 근성가이. All rights reserved.
//

import UIKit

class ListViewController: OnTheMapViewController {
    //MARK: - Properties
    @IBOutlet weak var tableView: UITableView!
}

//MARL: - OnTheMapViewController
extension ListViewController {
    override func refreshAction() {
        NetworkClient.sharedInstance().getStudentLocations() { success, errorString in
            guard success == true else {
                print("viewDidLoad_\(errorString)")
                return
            }
            
            performUIUpdatesOnMain {
                self.tableView.reloadData()
            }
        }
    }
}

//MARK: - UITableViewDelegate
extension ListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let mediaURLString = Student.sharedInstance().locations[indexPath.row].mediaURL
    
        openURL(mediaURLString)
    }
}

//MARK: - UITableViewDataSource
extension ListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Student.sharedInstance().locations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell", for: indexPath) as! LocationCell
        cell.nameLabel.text = Student.sharedInstance().locations[indexPath.row].fullName
        
        return cell
    }
}
