//
//  PlaceFinderViewController.swift
//  WorldTrip
//
//  Created by Erick Borges on 24/05/21.
//

import UIKit
import MapKit

//2-salvar dados no device(esta delegando para essa classe a tarefa de salvar os locais)

//MARK: - protocol PlaceFinderDelegate
protocol PlaceFinderDelegate: class {
    func addPlace(_ place: Place)
}

//MARK: - PlaceFinderViewController
class PlaceFinderViewController: UIViewController {
    
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var loading: UIActivityIndicatorView!
    @IBOutlet weak var viewLoading: UIView!
    
    var place: Place!
    weak var delegate: PlaceFinderDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //encontrar o local interagindo com o mapa
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(getLocation(_:)))
        gesture.minimumPressDuration = 2.0
        mapView.addGestureRecognizer(gesture)
    }
    
    @objc func getLocation(_ gesture: UILongPressGestureRecognizer) {
        //configurar o estado do GestureRecognizer
        if gesture.state == .began {
            load(show: true)
            //converter em coordenada o ponto tocado no mapview
            let point = gesture.location(in: mapView)
            let coordinate = mapView.convert(point, toCoordinateFrom: mapView)
            //transformar em localizacao a partir das coordenadas
            let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
            
            CLGeocoder().reverseGeocodeLocation(location, completionHandler: { (placemarks, error) in
                self.load(show: false)
                
                if error == nil {
                    if !self.savePlace(with: placemarks?.first) {
                        self.showMessage(type: .error("Não foi encontrado nenhum local com esse nome"))
                    }
                } else {
                    self.showMessage(type: .error("Erro desconhecido"))
                }
            })
        }
    }
    
    

    @IBAction func chooseButton(_ sender: UIButton) {
        searchTextField.resignFirstResponder()
        
        if searchTextField.text != nil {
            let place = searchTextField.text!
            load(show: true)
            let cLGeocoder = CLGeocoder()
            
            cLGeocoder.geocodeAddressString(place, completionHandler: { (placemarks, error) in
                self.load(show: false)
                
                if error == nil {
                    if !self.savePlace(with: placemarks?.first) {
                        self.showMessage(type: .error("Não foi encontrado nenhum local com esse nome"))
                    }
                } else {
                    self.showMessage(type: .error("Erro desconhecido"))
                }
            })
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
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 3500, longitudinalMeters: 3500)
        
        //mostrar no mapa
        mapView.setRegion(region, animated: true)
        
        self.showMessage(type: .confirmation(place.name))
        
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
            message = errorMessage
        }
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        
        alert.addAction(cancelAction)

        if hasConfirmation {
            let confirmAction = UIAlertAction(title: "OK", style: .default) { (alertAction) in
                
                //3-salvar dados no device(a paritr dessa acao será salvo)
                self.delegate?.addPlace(self.place)
                self.dismiss(animated: true, completion: nil)
            }
            alert.addAction(confirmAction)
        }
        
        //mostrar o alerta na tela
        present(alert, animated: true, completion: nil)
    }
}
