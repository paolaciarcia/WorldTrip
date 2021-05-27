//
//  MapViewController.swift
//  WorldTrip
//
//  Created by Erick Borges on 24/05/21.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    
    //todos os lugares a serem visualizados
    var allPlaces: [Place]!
    
    var pointsOfInterest: [MKAnnotation] = []
    lazy var locationManager = CLLocationManager()
    var userLocationButton: MKUserTrackingButton!
    var selectedAnnotation: CustomAnnotation?
    
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var placeName: UILabel!
    @IBOutlet weak var addressName: UILabel!
    @IBOutlet weak var viewInfo: UIView!
    @IBOutlet weak var loading: UIActivityIndicatorView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.isHidden = true
        viewInfo.isHidden = true
        mapView.mapType = .mutedStandard
        
        mapView.delegate = self
        searchBar.delegate = self
        locationManager.delegate = self
        
        setupNavigationTitle()
        
        for place in allPlaces {
            addPlacesToMap(place)
        }
        
        configureLocationButton()
        showPlaces()
        requestUserLocationAuth()
    }
    
    func setupNavigationTitle() {
        if allPlaces.count == 1 {
            title = allPlaces[0].name
        } else {
            title = "Meus lugares"
        }
    }
    
    func configureLocationButton() {
        userLocationButton = MKUserTrackingButton(mapView: mapView)
        userLocationButton.backgroundColor = .white
        userLocationButton.frame.origin.x = 10
        userLocationButton.frame.origin.y = 10
        userLocationButton.layer.cornerRadius = 5
        userLocationButton.layer.borderWidth = 1
        userLocationButton.layer.borderColor = UIColor(named: "main")?.cgColor
        userLocationButton.tintColor = UIColor(named: "main")
    }

    @IBAction func plotRoute(_ sender: UIButton) {
        //1-traçar rota
        //verifica não foi selecionado o authorizedWhenInUse
        if locationManager.authorizationStatus != .authorizedWhenInUse {
            showMessage(type: .authorizationWarning)
            return
        }
        
        let request = MKDirections.Request()
        if selectedAnnotation != nil {
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: selectedAnnotation!.coordinate))
            request.source = MKMapItem(placemark: MKPlacemark(coordinate: locationManager.location!.coordinate))
            
            let directions = MKDirections(request: request)
            directions.calculate { (response, error) in
                if error == nil {
                    if let response = response {
                        //overlays são camadas de infos que podem ser colocadas sobre o mapa
                        self.mapView.removeOverlays(self.mapView.overlays)
                        
                        let route = response.routes.first!
                        print("Name: \(route.name)")
                        print("Distance: \(route.distance)")
                        print("Duracao: \(route.expectedTravelTime)")
                        print("============")
                        
                        for step in route.steps {
                            print("Em \(step.distance) metro(s), \(step.instructions)")
                        }
                        
                        self.mapView.addOverlay(route.polyline, level: .aboveLabels)
                        //filtro que vai pegar apenas a localização do usuário
                        var annotations = self.mapView.annotations.filter { !($0 is CustomAnnotation )}
                        
                        //array contendo a annotation selecionada
                        annotations.append(self.selectedAnnotation!)
                        self.mapView.showAnnotations(annotations, animated: true)
                    }
                } else {
                    self.showMessage(type: .routeError)
                }
            }
        }
    }
    
    @IBAction func showSearchBar(_ sender: UIBarButtonItem) {
        searchBar.resignFirstResponder()
        searchBar.isHidden = !searchBar.isHidden
    }
    //validar a ativação de localização
    func requestUserLocationAuth() {
        if CLLocationManager.locationServicesEnabled() {
            
            switch locationManager.authorizationStatus {
            case .authorizedAlways, .authorizedWhenInUse:
                //mostrar botão de localização no mapa
                mapView.addSubview(userLocationButton)
                break
            case .denied:
                showMessage(type: .authorizationWarning)
            case .notDetermined:
                locationManager.requestWhenInUseAuthorization()
            case .restricted:
                break
            default:
                return
            }
        }
    }
    
    func showMessage(type: MapMessageType.Alerts) {
        //alerts para avisar o usuário sobre a configuração de localizaçÃo
        let title = type == .authorizationWarning ? "Ops" : "Algo deu errado"
        let message = type == .authorizationWarning ? "Para usar os recursos de localização do App, você precisa permitir o uso em Ajustes" : "Não conseguimos encontrar esta rota"
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        
        alert.addAction(cancelAction)
        
        if type == .authorizationWarning  {
            let confirmAction = UIAlertAction(title: "Ir para Ajustes", style: .default) { (action) in
                
                //levar o usuário para a tela de ajustes
                if let appSettings = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(appSettings, options: [:], completionHandler: nil)
                }
            }
            alert.addAction(confirmAction)
        }
        present(alert, animated: true, completion: nil)
    }

    
    //implementacao do MKAnnotation - "pinos" que são inseridos no mapa
    func addPlacesToMap(_ place: Place) {
        let annotation = CustomAnnotation.init(coordinate: place.coordinate, type: .place)
        
        annotation.coordinate = place.coordinate
        annotation.title = place.name
        annotation.subtitle = place.address
        
        mapView.addAnnotation(annotation)
        
        //mostrar todas as anotacoes que o mapa tem, mesmo que estejam distantes
        showPlaces()
    }
    
    func showPlaces() {
        mapView.showAnnotations(mapView.annotations, animated: true)
    }
    
    func showDescription() {
        placeName.text = selectedAnnotation?.title
        addressName.text = selectedAnnotation?.address
        viewInfo.isHidden = false
    }
}

//MARK: - MKMapViewDelegate

extension MapViewController: MKMapViewDelegate {
    //método utilizado para modificar uma annotation view
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if !(annotation is CustomAnnotation) {
            return nil
        } else {
        
            let type = (annotation as! CustomAnnotation).type
            let identifier = "\(type)"
            
            //annotation reutilizavel
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView
            
            if annotationView == nil {
                annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            }
            
            annotationView?.annotation = annotation
            annotationView?.canShowCallout = true
            annotationView?.markerTintColor = type == .place ? UIColor(named: "main") : UIColor(named: "pointInterest")
            annotationView?.glyphImage = type == .place ? #imageLiteral(resourceName: "placeGlyph") : #imageLiteral(resourceName: "poiGlyph")
            annotationView?.displayPriority = type == .place ? .required : .defaultHigh
            
            return annotationView
        }
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        //mostra o mapa em 3D quando uma annotation é selecionada
        let camera = MKMapCamera()
        guard let annotationView = view.annotation else { return }
        camera.centerCoordinate = annotationView.coordinate
        camera.pitch = 80
        camera.altitude = 100
        mapView.setCamera(camera, animated: true)
        
        selectedAnnotation = (view.annotation as! CustomAnnotation)
        showDescription()
    }
    
    //2 - traçar rota
    //método responsavel por renderizar o overlay
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        if overlay is MKPolyline {
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = UIColor(named: "main")?.withAlphaComponent(0.8)
            renderer.lineWidth = 5
            
            return renderer
        }
        return MKOverlayRenderer(overlay: overlay)
    }
}

//MARK: - UISearchBarDelegate

//pesquisa por pontos de interesse
extension MapViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.isHidden = true
        searchBar.resignFirstResponder()
        loading.startAnimating()
        
        //dados da requisicao
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchBar.text
        request.region = mapView.region
        
        //execução da requisição
        let search = MKLocalSearch(request: request)
        search.start { (response, error) in
            if error == nil {
                guard let response = response else {
                    self.loading.stopAnimating()
                    return
                }
                
                self.mapView.removeAnnotations(self.pointsOfInterest)
                self.pointsOfInterest.removeAll()
                
                for item in response.mapItems {
                    let annotation = CustomAnnotation(coordinate: item.placemark.coordinate , type: .pointInterest)
                    annotation.title = item.name
                    annotation.subtitle = item.phoneNumber
                    annotation.address = Place.getFormattedAddress(with: item.placemark)
                    self.pointsOfInterest.append(annotation)
                }
                
                self.mapView.addAnnotations(self.pointsOfInterest)
                self.mapView.showAnnotations(self.pointsOfInterest, animated: true)
            }
            
            self.loading.stopAnimating()
        }
    }
}

//MARK: - CLLocationManagerDelegate

extension MapViewController: CLLocationManagerDelegate {
    //muda o status da autorização. É possivel saber se o usuário autorizou ou não.
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            mapView.showsUserLocation = true
            mapView.addSubview(userLocationButton)
            locationManager.startUpdatingLocation()
        default:
            break
        }
    }
    
    //metodo chamado sempre que o usuário modificar sua localização
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //metodo chamado sempre que o usuário modificar sua localização
//        if let currentLocation = locations.last {
//            print("Velocidade: \(currentLocation.speed)")
//
//            let region = MKCoordinateRegion(center: currentLocation.coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
//            mapView.setRegion(region, animated: true)
//        }
    }
}
