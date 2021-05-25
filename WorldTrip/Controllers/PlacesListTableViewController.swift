//
//  PlacesListTableViewController.swift
//  WorldTrip
//
//  Created by Erick Borges on 24/05/21.
//

import UIKit

class PlacesListTableViewController: UITableViewController {
    
    var places: [Place] = []
    let ud = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadPlaces()
        savePlaces()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier! != "showPlace" {
            let mapVC = segue.destination as! PlaceFinderViewController
            mapVC.delegate = self
        }
    }
    
    //1-salvar dados no device
    func loadPlaces() {
        if let placesData = ud.data(forKey: "places") {
            do {
            places = try JSONDecoder().decode([Place].self, from: placesData)
                tableView.reloadData()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func savePlaces() {
        let json = try? JSONEncoder().encode(places)
        ud.set(json, forKey: "places")
    }
    
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let place = places[indexPath.row]
        cell.textLabel?.text = place.name
        
        return cell
    }
}

//4-salvar dados no device
extension PlacesListTableViewController: PlaceFinderDelegate {
    func addPlace(_ place: Place) {
        //places.append(place) - mas acaba adicionando lugares repetidos
        
        //em Place na extension é feita uma comparacao entre 2 classes
        if !places.contains(place) {
            places.append(place)
            
            //1-persistir os dados salvos
            savePlaces()
            tableView.reloadData()
        }
    }
}
