//
//  CustomAnnotation.swift
//  WorldTrip
//
//  Created by Erick Borges on 26/05/21.
//

import UIKit
import MapKit

class CustomAnnotation: NSObject, MKAnnotation {
    
    enum PlaceType {
        case place
        case pointInterest
    }
    
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var type: PlaceType
    var address: String?
    
    init(coordinate: CLLocationCoordinate2D, type: PlaceType) {
        self.coordinate = coordinate
        self.type = type
    }
    
    
}
