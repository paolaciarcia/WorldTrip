//
//  PlaceFinderViewController.swift
//  WorldTrip
//
//  Created by Erick Borges on 24/05/21.
//

import UIKit
import MapKit

class PlaceFinderViewController: UIViewController {
    
    var place: Place!
    
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
                
                if error == nil {
                    if !self.savePlace(with: placemarks?.first) {
                        self.showMessage(type: .error("Não foi encontrado nenhum local com esse nome"))
                    }
                } else {
                    self.showMessage(type: .error("Erro desconhecido"))
                }
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
    
    func savePlace(with placemark: CLPlacemark?) -> Bool {
        
        guard let placemark = placemark, let coordinate = placemark.location?.coordinate else { return false }
        
        let name = placemark.name ?? placemark.country ?? "Desconhecido"
        let address = Place.getFormattedAddress(with: placemark)
        
        place = Place(name: name, lat: coordinate.latitude, long: coordinate.longitude, address: address)
        
        //região a ser mostrada no mapa
        let region = MKCoordinateRegion(center: coordinate , latitudinalMeters: 3500, longitudinalMeters: 3500)
        
        self.showMessage(type: .confirmation(place.name))
        
        //mostrar no mapa
        mapView.setRegion(region, animated: true)

        return true
    }
    
    func showMessage(type: Constants.PlaceFinderMessageType) {

        let title: String
        let message: String
        var hasConfirmation: Bool = false
        
        switch type {
        case .confirmation(let name):
            title = "Local encontrado"
            message = "Deseja adicionar \(name) ?"
            hasConfirmation = true
        case .error(let errorMessage):
            title = "Erro"
            message = "\(errorMessage)"
        }
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        
        alert.addAction(cancelAction)

        if hasConfirmation {
            let confirmAction = UIAlertAction(title: "OK", style: .default, handler: { (alertAction) in
                print("ok")
            })
            alert.addAction(confirmAction)
        }
        
        //mostrar o alerta na tela
        present(alert, animated: true, completion: nil)
    }
}
