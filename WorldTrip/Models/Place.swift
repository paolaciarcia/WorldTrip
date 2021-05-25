//
//  Place.swift
//  WorldTrip
//
//  Created by Erick Borges on 24/05/21.
//

import Foundation
import MapKit


struct Place: Codable {
    let name: String
    let lat: CLLocationDegrees
    let long: CLLocationDegrees
    let address: String
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: lat, longitude: long)
    }
    
    static func getFormattedAddress(with placemark: CLPlacemark) -> String {
        var address = ""
        
        if let street = placemark.thoroughfare {
            address += street
        }
        if let number = placemark.subThoroughfare {
            address += "\(number)"
        }
        if let subLocality = placemark.subLocality {
            address += ", \(subLocality)" //Bairro
        }
        if let city = placemark.locality {
            address += "\n\(city)"
        }
        if let state = placemark.administrativeArea {
            address += " - \(state)"
        }
        if let postalCode = placemark.postalCode {
            address += "\nCEP: \(postalCode)"
        }
        if let county = placemark.country {
            address += "\n\(county)"
        }
        return address
    }
}

//5-salvar dados no device(compara se duas classes são iguais)
extension Place: Equatable {
    static func ==(lhs: Place, rhs: Place) -> Bool {
        return lhs.lat == rhs.lat && lhs.long == rhs.long
    }
}
