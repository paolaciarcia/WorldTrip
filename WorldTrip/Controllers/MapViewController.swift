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
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var placeName: UILabel!
    @IBOutlet weak var addressName: UILabel!
    @IBOutlet weak var viewInfo: UIView!
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.isHidden = true
        viewInfo.isHidden = true
        
        if allPlaces.count == 1 {
            title = allPlaces[0].name
        } else {
            title = "Meus lugares"
        }
        
        
        for place in allPlaces {
            addPlacesToMap(place)
        }

        // Do any additional setup after loading the view.
    }

    @IBAction func plotRoute(_ sender: UIButton) {
    }
    @IBAction func showSearchBar(_ sender: UIBarButtonItem) {
    }
    
    //implementacao do MKAnnotation - "pinos" que são inseridos no mapa
    func addPlacesToMap(_ place: Place) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = place.coordinate
        annotation.title = place.name
        //annotation.subtitle = place.address
        mapView.addAnnotation(annotation)
        
        //mostrar todas as anotacoes que o mapa tem, mesmo que estejam distantes
        showPlaces()
    }
    
    func showPlaces() {
        mapView.showAnnotations(mapView.annotations, animated: true)
    }
}
