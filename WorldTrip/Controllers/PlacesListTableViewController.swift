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
    //label de inicio quando não há nenhum lugar salvo pelo usuário
    var startedLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadPlaces()
        setupLabel()
        //savePlaces()
    }
    
    func setupLabel() {
        startedLabel = UILabel()
        startedLabel.text = "Adicione os lugares que deseja conhecer\nclicando no botão + acima"
        startedLabel.textAlignment = .center
        startedLabel.numberOfLines = 0
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier! != "showPlace" {
            let mapVC = segue.destination as! PlaceFinderViewController
            mapVC.delegate = self
        } else {
            //informações apresentadas para a próxima tela
            //caso o usuário escolha um lugar específico, será mostradas infos especificas do lugar ecolhido. Caso ele nao escolha um lugar especifico, todos os lugares serão mostrados no mapa pelo botão Mostrar lugares no mapa
            let vc = segue.destination as! MapViewController
            
            switch sender {
            case let place as Place:
                vc.allPlaces = [place]
            default:
                vc.allPlaces = places
            }
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
        //mostrar o botão caso o número de lugares selecionados seja maior que 0
        if places.count > 0 {
            let showPlacesButton = UIBarButtonItem(title: "Mostrar lugares no mapa", style: .plain, target: self, action: #selector(showAll))
            navigationItem.leftBarButtonItem = showPlacesButton
            tableView.backgroundView = nil
        } else {
            navigationItem.leftBarButtonItem = nil
            tableView.backgroundView = startedLabel
        }
        
        
        return places.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let place = places[indexPath.row]
        cell.textLabel?.text = place.name
        
        return cell
    }
    
    //marcar no mapa o lugar que usuário selecionou
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let place = places[indexPath.row]
        performSegue(withIdentifier: "showPlace", sender: place)
    }
    
    //mostrar todos os lugares selecionados no mapa
    @objc func showAll() {
        performSegue(withIdentifier: "showPlace", sender: nil)
    }
    
    //permite remover celulas existentes na tableView
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            places.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            savePlaces()
        }
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
