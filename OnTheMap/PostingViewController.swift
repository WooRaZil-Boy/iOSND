//
//  PostingViewController.swift
//  OnTheMap
//
//  Created by 근성가이 on 2017. 3. 9..
//  Copyright © 2017년 근성가이. All rights reserved.
//

import UIKit
import MapKit

class PostingViewController: UIViewController, Spinner_Protocol {
    //MARK: - Properties
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var findButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var mediaURLTextField: UITextField!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    var latitude = 0.0
    var longitude = 0.0
}

//MARK: - Actions
extension PostingViewController {
    @IBAction func cancelAction(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func findAction(_ sender: UIButton) {
        mapView.isHidden = false
        
        spinnerAimation(true)
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(searchTextField.text!) { placemarks, error in
            self.spinnerAimation(false)
            
            guard error == nil else {
                let alertController = UIAlertController(title: "Error", message: "Unable to find that location", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default)
                alertController.addAction(okAction)
                self.present(alertController, animated: true)
                
                return
            }
            
            let location = placemarks?.first?.location
            self.latitude = (location?.coordinate.latitude)! as Double
            self.longitude = (location?.coordinate.longitude)! as Double
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = (location?.coordinate)!
            
            self.mapView.addAnnotation(annotation)
            self.mapView.camera.centerCoordinate = (location?.coordinate)!
            self.mapView.camera.altitude = self.mapView.camera.altitude * 0.2
            
            self.updateUI()
        }
    }
    
    @IBAction func submitAction(_ sender: UIButton) {
        let mapString = searchTextField.text!
        let mediaURL = mediaURLTextField.text!
        
        spinnerAimation(true)

        NetworkClient.sharedInstance().setStudentLocation(mapString: mapString, mediaURL: mediaURL, latitude: latitude, longitude: longitude) { success, errorString in
            self.spinnerAimation(false)
            
            guard success == true else {
                print("submitAction_\(errorString)")
                
                let alertController = UIAlertController(title: "Submit Error", message: errorString, preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default)
                alertController.addAction(okAction)
                
                performUIUpdatesOnMain {
                    self.present(alertController, animated: true)
                }
                
                return
            }
            
            performUIUpdatesOnMain {
                self.dismiss(animated: true)
            }
        }
    }
    
    func updateUI() {
        stackView.isHidden = !stackView.isHidden
        findButton.isHidden = !findButton.isHidden
        submitButton.isHidden = !submitButton.isHidden
        searchTextField.isHidden = !searchTextField.isHidden
        mediaURLTextField.isHidden = !mediaURLTextField.isHidden
    }
}

//MARK: - UITextFieldDelegate
extension PostingViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
}
