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
    var locations: [Location]!
    
    //MARK: - ViewLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let appdelegateLocations = NetworkClient.sharedInstance().locations {
            locations = appdelegateLocations
        }
    }
}

//MARL: - OnTheMapViewController
extension ListViewController {
    override func refreshAction(_ locations: [Location]) {
        performUIUpdatesOnMain {
            self.locations = locations
            self.tableView.reloadData()
        }
    }
}

//MARK: - UITableViewDelegate
extension ListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let mediaURLString = locations[indexPath.row].mediaURL
    
        openURL(mediaURLString)
    }
}

//MARK: - UITableViewDataSource
extension ListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell", for: indexPath) as! LocationCell
        cell.nameLabel.text = locations[indexPath.row].fullName
        
        return cell
    }
}
