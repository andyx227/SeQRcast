//
//  MapViewController.swift
//  SeQRcast
//
//  Created by user149673 on 5/26/19.
//  Copyright © 2019 Ground Zero. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var notFoundCoverView: UIView!
    
    var latitude = 999.0
    var longitude = 999.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.addSubview(closeButton)
        let loc = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let radius: CLLocationDistance = 1000.0
        let region = MKCoordinateRegion(center: loc, latitudinalMeters: radius, longitudinalMeters: radius)
        let annotation = MKPointAnnotation()
        annotation.coordinate = loc
        if CLLocationCoordinate2DIsValid(loc) {
            mapView.setRegion(region, animated: true)
            mapView.addAnnotation(annotation)
        }
        else {
            notFoundCoverView.isHidden = false
            notFoundCoverView.addSubview(closeButton)
        }
        // Do any additional setup after loading the view.
    }

    
    @IBAction func close(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
