//
//  MeusDadosVC.swift
//  FideliCash-Comerciante
//
//  Created by Carlos Doki on 09/06/18.
//  Copyright © 2018 Carlos Doki. All rights reserved.
//

import UIKit
import FirebaseAuth
import SwiftKeychainWrapper
import Firebase

class MeusDadosVC: UIViewController {

    @IBOutlet weak var nomeTxt: UITextField!
    @IBOutlet weak var emailTxt: UITextField!
    @IBOutlet weak var telefoneTxt: UITextField!
    @IBOutlet weak var cpfTxt: UITextField!
    @IBOutlet weak var photoURL: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        nomeTxt.setBottomLine(borderColor: nomeTxt.textColor!)
        emailTxt.setBottomLine(borderColor: emailTxt.textColor!)
        telefoneTxt.setBottomLine(borderColor: telefoneTxt.textColor!)
        cpfTxt.setBottomLine(borderColor: cpfTxt.textColor!)
        
        // Do any additional setup after loading the view.
        let user = Auth.auth().currentUser
        if let user = user {
            emailTxt.text = user.email
            photoURL.load(url: user.photoURL!)
            nomeTxt.text = user.displayName
            telefoneTxt.text = user.phoneNumber
        }
        cpfTxt.text = UserCPF
    }

    @IBAction func btnSairPressed(_ sender: RoundedButton) {
        let alert = UIAlertController(title: "FideliCash", message: "Confirma o logout?", preferredStyle: .alert)
        let action = UIAlertAction(title: "Sim", style: .default) { (UIAlertAction) in
            let firebaseAuth = Auth.auth()
            do {
                try firebaseAuth.signOut()
                KeychainWrapper.standard.removeObject(forKey: KEY_UID)
                exit(0)
            } catch let signOutError as NSError {
                print ("Error signing out: %@", signOutError)
            }
        }
        let cancel = UIAlertAction(title: "Não", style: .cancel, handler: nil)
        alert.addAction(action)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func salvarBtnPressed(_ sender: RoundedButton) {
        if (cpfTxt.text == "") {
            let alert = UIAlertController(title: "Alerta", message: "Número de CPF inválido ou incompleto", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else {
            let user = Auth.auth().currentUser
            let ref = Database.database().reference()
            let users = ref.child("users").child((user?.uid)!)
            users.child("cpf").setValue(cpfTxt.text)
        }
    }
}

extension UIImageView {
    func load(url: URL) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
}
