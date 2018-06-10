//
//  TransferiConfirmarVC.swift
//  FideliCash-Comerciante
//
//  Created by Carlos Doki on 09/06/18.
//  Copyright © 2018 Carlos Doki. All rights reserved.
//

import UIKit
import Alamofire
import SwiftKeychainWrapper
import Firebase

class TransferiConfirmarVC: UIViewController {
    
    @IBOutlet weak var cpfLbl: UITextField!
    @IBOutlet weak var valorLbl: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func voltarBtnPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func transferirBtnPressed(_ sender: RoundedButton) {
        
        let origin = KeychainWrapper.standard.string(forKey: KEY_UID)!
        var target = ""
        let cpftarget = self.cpfLbl!.text
        DataService.ds.REF_USERS.queryOrdered(byChild: "cpf").queryEqual(toValue: self.cpfLbl!.text).observeSingleEvent(of: .value, with: { (snapshot) in
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                for snap in snapshot {
                    target = snap.key
                }
            }
            let cost2 = (self.valorLbl.text! as NSString).doubleValue
            
            if target != "" {
                let param2 = [
                    "origin":origin,
                    "target":target,
                    "value": cost2
                    ] as [String : Any]
                let url = "http://fddcdf7e.ngrok.io/users/transaction"
                Alamofire.request(url, method:.post, parameters:param2,encoding: JSONEncoding.default).responseJSON { response in
                    switch response.result {
                    case .success:
                        print("Transferencia com sucesso")
                        self.dismiss(animated: true, completion: nil)
                    case .failure(let error):
                        //self.activityIndicator.stopAnimating()
                        //self.performSegue(withIdentifier: "menuprincipal2", sender: nil)
                        print("Erro na transferencia", error)
                    }
                }
            } else {
                print("Target não encontrado!", self.cpfLbl!.text)
            }
        })
    }
}
