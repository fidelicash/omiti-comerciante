//
//  SaldoVC.swift
//  FideliCash-Comerciante
//
//  Created by Carlos Doki on 09/06/18.
//  Copyright © 2018 Carlos Doki. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase
import SwiftKeychainWrapper

class SaldoVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate {
    
    @IBOutlet weak var saldoLbl: UILabel!
    @IBOutlet weak var historicoTV: UITableView!
    @IBOutlet weak var activityView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    var historico = [Historico]()
    var userref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityView.isHidden = false
        activityIndicator.startAnimating()
        
        // Do any additional setup after loading the view.
        historicoTV.delegate = self
        historicoTV.dataSource = self
        
        DataService.ds.REF_HISTORY.observe(.value, with: { (snapshot) in
            //        DataService.ds.REF_HISTORY.queryOrdered(byChild: "origin").queryEqual(toValue: KeychainWrapper.standard.string(forKey: KEY_UID)!).observe(.value, with: { (snapshot) in
            self.historico.removeAll()
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                for snap in snapshot {
                    if let postDict = snap.value as? Dictionary<String, AnyObject> {
                        let key = snap.key
                        if (postDict["origin"] as! String) == (KeychainWrapper.standard.string(forKey: KEY_UID)!) || (postDict["target"] as! String) == (KeychainWrapper.standard.string(forKey: KEY_UID)!) {
                            let post = Historico(postKey: key, postData: postDict)
                            self.historico.append(post)
                        }
                    }
                }
            }

            self.historicoTV.reloadData()
            self.activityView.isHidden = true
            self.activityIndicator.stopAnimating()
            
            self.userref = DataService.ds.REF_USER_CURRENT
            self.userref.observeSingleEvent(of: .value, with: { (snapshot) in
                let value = snapshot.value as? NSDictionary
                if let valor = value?["saldo"] as? Double {
                    self.saldoLbl.text = "\(String(format: "%.2f", valor))"
                }
                UserCPF = (value?["cpf"] as? String)!
            })
        })
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return historico.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let post = historico[indexPath.row]
        if let cell = tableView.dequeueReusableCell(withIdentifier: "HistoricoCell") as? HistoricoTVC {
            cell.configureCell(date: post.date, origin: post.origin, target: post.target, value: post.value)
            return cell
        } else {
            return HistoricoTVC()
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}
