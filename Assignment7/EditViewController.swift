//
//  EditViewController.swift
//  Assignment7
//
//  Created by Azamat Sharapat on 11/5/20.
//  Copyright © 2020 Azamat Sharapat All rights reserved.
//

import UIKit

class EditViewController: UIViewController {
    
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var placeTextField: UITextField!
    
    var myProtocol: Protocol?
    var cityText: String?
    var placeText: String?
    var index = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        cityTextField.text = cityText
        placeTextField.text = placeText
    }
    
    @IBAction func cancelPressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
    
    @IBAction func donePressed(_ sender: Any) {
        myProtocol?.changeText(cityTitle: cityTextField.text!, placeTitle: placeTextField.text!, index: index)
    }
    
}
