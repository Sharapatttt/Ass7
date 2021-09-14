//
//  ViewController.swift
//  Assignment7
//
//  Created by Azamat Sharapat on 11/4/20.
//  Copyright © 2020 Azamat Sharapat All rights reserved.
//

import UIKit
import MapKit
import CoreData

class ViewController: UIViewController {
    
    @IBOutlet weak var myTableView: UITableView!
    @IBOutlet weak var mySegment: UISegmentedControl!
    @IBOutlet weak var myMap: MKMapView!
    
    var points: [Point] = []
    var annotation: MKAnnotation?
    var i = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        myTableView.isHidden = true
        myMap.delegate = self
        
        points = loadPoint()
        configureMap()
        setupActions()
    }
    @objc func handleTouchSegment() {
        switch mySegment.selectedSegmentIndex {
        case 0:
            myMap?.mapType = .standard
        case 1:
            myMap?.mapType = .satellite
        default:
            myMap?.mapType = .hybrid
        }
    }

    private func configureMap() {
        let location = CLLocationCoordinate2DMake(45.12, 66.87)
        let span = MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1)
        let region = MKCoordinateRegion(center: location, span: span)
        myMap?.setRegion(region, animated: true)
        points.forEach { (entity) in
            let annotation = MKPointAnnotation()
            let coordinate = CLLocationCoordinate2D(latitude: entity.latitude, longitude: entity.longitude)
            annotation.coordinate = coordinate
            annotation.title = entity.title
            annotation.subtitle = entity.subtitle
            self.myMap.addAnnotation(annotation)
        }
    }
    
   
    
    
    @objc func infoAction(sender: UIButton) {
        let vc = storyboard?.instantiateViewController(identifier: "EditViewController") as! EditViewController
        vc.cityText = annotation?.title ?? ""
        vc.placeText = annotation?.subtitle ?? ""
        vc.index = 0
        show(vc, sender: self)
    }
    /*
    @IBAction func addPin(_ sender: UILongPressGestureRecognizer) {
        switch sender.state {
            case .began:
                let annotation = MKPointAnnotation()
                annotation.coordinate = MapView.convert(sender.location(in: MapView), toCoordinateFrom: MapView)
                annotation.title =  "Untitled"
                MapView.addAnnotation(annotation)
            case .changed:
                if let annotation = (MapView.annotations.filter{$0.title! == "Untitled" }).first as? MKPointAnnotation {
                    annotation.coordinate =  MapView.convert(sender.location(in: MapView), toCoordinateFrom: MapView)
                }
            case .cancelled:
                if let annotation = (MapView.annotations.filter{$0.title! == "Untitled" }).first as? MKPointAnnotation {
                    MapView.removeAnnotation(annotation)
                }
            // you can also prompt the user here for the annotation title
            case .ended:
                if let annotation = (MapView.annotations.filter{$0.title! == "Untitled" }).first as? MKPointAnnotation {
                    let alert = UIAlertController(title: "New Annotation", message: "", preferredStyle: .alert)
                    var inputTextField: UITextField?
                    var inputTextFieldd: UITextField?
                    alert.addAction(UIAlertAction(title: "Add", style: .default) { _ in
                        if  let annotationTitle = inputTextField?.text {
                            annotation.title =  annotationTitle
                            
                        }
                        if  let annotationTitle = inputTextFieldd?.text {
                            annotation.subtitle =  annotationTitle
                            
                        }
                    })
                    alert.addTextField(configurationHandler: { textField in
                        textField.placeholder = "Title"
                        inputTextField = textField
                    })
                    alert.addTextField(configurationHandler: { textField in
                        textField.placeholder = "Subtitle"
                        inputTextFieldd = textField
                    })
                    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel){ _ in
                        self.MapView.removeAnnotation(annotation)
                    })
                    present(alert, animated: true, completion: nil)
                }
            default:
                print("default")
            }*/
       
    @objc func handleTapGesture(gestureReconizer: UILongPressGestureRecognizer) {
        let alert = UIAlertController(title: "Add Place", message: "Fill all the fields", preferredStyle: .alert)
        alert.addTextField { (textfield) in
            textfield.placeholder = "Enter title"
        }
        alert.addTextField { (textfield) in
            textfield.placeholder = "Enter subtitle"
        }
        
        let location = gestureReconizer.location(in: self.myMap)
        let coordinate = self.myMap.convert(location, toCoordinateFrom: self.myMap)
        alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { (UIAlertAction) in
            let cityTitle = alert.textFields![0].text ?? ""
            let placeTitle = alert.textFields![1].text ?? ""
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = cityTitle
            annotation.subtitle = placeTitle
            
            self.myMap.addAnnotation(annotation)
            self.savePoint(cityTitle: cityTitle, placeTitle: placeTitle, latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude)

            self.myTableView.reloadData()
            
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        self.present(alert, animated: true)
    }
    private func setupActions() {
        myMap.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(handleTapGesture)))
        
        mySegment.addTarget(self, action: #selector(handleTouchSegment), for: .valueChanged)
        
    }
    
    func drawAnnotations() {
        let removeAnnotations = self.myMap.annotations
        myMap.addAnnotations(removeAnnotations)
    }
    @IBAction func folderPressed(_ sender: UIBarButtonItem) {
        if myTableView.isHidden {
            myTableView.isHidden = false
        } else {
            myTableView.isHidden = true
        }
    }
    
    func deleteGOT(object: Point) {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            myMap.removeAnnotations(myMap.annotations)
            let context = appDelegate.persistentContainer.viewContext
            context.delete(object)
            do {
                try context.save()
            } catch {
                
            }
        }
    }
    
    func loadPoint() -> [Point] {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            let context = appDelegate.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<Point>(entityName: "Point")
            do {
                try points = context.fetch(fetchRequest)
            } catch {
                print("Hello error")
            }
        }
        return points
    }
    
    func savePoint(cityTitle: String, placeTitle: String, latitude: Double, longitude: Double) {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            let context = appDelegate.persistentContainer.viewContext
            if let entity = NSEntityDescription.entity(forEntityName: "Point", in: context) {
                let character = NSManagedObject(entity: entity, insertInto: context)
                character.setValue(cityTitle, forKey: "title")
                character.setValue(placeTitle, forKey: "subtitle")
                character.setValue(latitude, forKey: "latitude")
                character.setValue(longitude, forKey: "longitude")
                do {
                    try context.save()
                    points.append(character as! Point)
                } catch {
                    print("Warning! Error is here!")
                }
            }
        }
    }

}

// MARK: - UITableViewDataSource, Delegate

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return points.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "myCell") as? TableViewCell
        cell?.textLabel!.text = points[indexPath.row].title
        cell?.detailTextLabel!.text = points[indexPath.row].subtitle
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        myTableView.deselectRow(at: indexPath, animated: true)
        myTableView.isHidden = true
        let coordinate = CLLocationCoordinate2DMake(points[indexPath.row].latitude, points[indexPath.row].longitude)
        let annotation = myMap.annotations
        let index = annotation.firstIndex { (result) -> Bool in
            return result.coordinate.latitude == coordinate.latitude
        }!
        i = index
        myMap.selectAnnotation(myMap.annotations[index], animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteGOT(object: points[indexPath.row])
            points = loadPoint()
            tableView.reloadData()
        }
    }
}

// MARK: - Map Delegate

extension ViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is MKPointAnnotation else { return nil }
        
        let identifier = "Annotation"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView!.canShowCallout = true
            let button = UIButton(type: .detailDisclosure)
            button.addTarget(self, action: #selector(infoAction), for: .touchUpInside)
            annotationView?.rightCalloutAccessoryView = button
        } else {
            annotationView!.annotation = annotation
        }
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        annotation = view.annotation
    }
}

extension ViewController: Protocol {
    func changeText(cityTitle: String, placeTitle: String, index: Int) {
        points[index].title = cityTitle
        points[index].subtitle = placeTitle
        myTableView.reloadData()
    }
}
