//
//  MapViewController.swift
//  OnTheMap
//
//  Created by 근성가이 on 2017. 3. 9..
//  Copyright © 2017년 근성가이. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: OnTheMapViewController {
    //MARK: - Properties
    var selectedMediaURL: String!
    @IBOutlet weak var mapView: MKMapView!
    
    //MARKL - ViewLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshAction()
    }
}

//MARK: - OnTheMapViewController
extension MapViewController {
    override func refreshAction() {
        NetworkClient.sharedInstance().getStudentLocations() { success, errorString in
            guard success == true else {
                print("viewDidLoad_\(errorString)")
                return
            }
            
            var annotations = [MKPointAnnotation]()
            let locations = Student.sharedInstance().locations
            for location in locations {
                let latitude = CLLocationDegrees(location.latitude)
                let longtitude = CLLocationDegrees(location.longitude)
                
                let annotation = MKPointAnnotation()
                annotation.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longtitude)
                annotation.title = location.fullName
                annotation.subtitle = location.mediaURL
                
                annotations.append(annotation)
            }
            
            performUIUpdatesOnMain {
                self.mapView.removeAnnotations(self.mapView.annotations)
                self.mapView.addAnnotations(annotations)
            }
        }
    }
}

//MARK: - Actions
extension MapViewController {
    func showMedia() {
        openURL(selectedMediaURL)
    }
}

//MARK: - MKMapViewDelegate
extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "Location"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        
        if let annotationView = annotationView {
            annotationView.annotation = annotation
        } else {
            let pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            
            pinView.isEnabled = true
            pinView.canShowCallout = true
            pinView.animatesDrop = false
            
            let rightButton = UIButton(type: .detailDisclosure) //annotation에 버튼 추가
            rightButton.addTarget(self, action: #selector(showMedia), for: .touchUpInside)
            pinView.rightCalloutAccessoryView = rightButton
            
            annotationView = pinView
        }
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let url = view.annotation?.subtitle
        selectedMediaURL = url!
    }
}
