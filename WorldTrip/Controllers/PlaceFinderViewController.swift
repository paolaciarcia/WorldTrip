//
//  PlaceFinderViewController.swift
//  WorldTrip
//
//  Created by Erick Borges on 24/05/21.
//

import UIKit
import MapKit

class PlaceFinderViewController: UIViewController {
    
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var loading: UIActivityIndicatorView!
    @IBOutlet weak var viewLoading: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }

    @IBAction func chooseButton(_ sender: UIButton) {
        searchTextField.resignFirstResponder()
        
        if searchTextField.text != nil {
            let place = searchTextField.text!
            load(show: true)
            let cLGeocoder = CLGeocoder()
        
            cLGeocoder.geocodeAddressString(place) { (placemarks, error) in
                self.load(show: false)
                
                guard let placeMark = placemarks?.first else { return }
                print("place: \(place)  placemarks: \(String(describing: placemarks?.first))")
                print(Place.getFormattedAddress(with: placeMark))
            }
        } 
    }
    
    
    @IBAction func closeButton(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    func load(show: Bool) {
        viewLoading.isHidden = !show
        if show {
            loading.startAnimating()
        } else {
            loading.stopAnimating()
        }
    }
    
}
