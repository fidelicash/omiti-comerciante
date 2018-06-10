//
//  TransferenciaVC.swift
//  FideliCash-Comerciante
//
//  Created by Carlos Doki on 09/06/18.
//  Copyright © 2018 Carlos Doki. All rights reserved.
//

import UIKit

class TransferenciaVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func transferirBtnPressed(_ sender: RoundedButton) {
        self.performSegue(withIdentifier: "transferir", sender: nil)
    }
    
    @IBAction func receberBtnPressed(_ sender: RoundedButton) {
        self.performSegue(withIdentifier: "receber", sender: nil)
    }
}
