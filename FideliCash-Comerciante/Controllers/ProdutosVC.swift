//
//  ProdutosVC.swift
//  FideliCash-Comerciante
//
//  Created by Carlos Doki on 10/06/18.
//  Copyright © 2018 Carlos Doki. All rights reserved.
//

import UIKit
import Firebase

class ProdutosVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate {
    
    @IBOutlet weak var produtoLbl: UITextField!
    @IBOutlet weak var valorLbl: UITextField!
    @IBOutlet weak var produtoTV: UITableView!
    @IBOutlet weak var excluirBtn: RoundedButton!
    
    var produtos = [Produtos]()
    var prd_postkey = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        produtoTV.delegate = self
        produtoTV.dataSource = self
        // Do any additional setup after loading the view.
        
        excluirBtn.isEnabled = false
        
        DataService.ds.REF_PRODUTO.observe(.value, with: { (snapshot) in
            self.produtos.removeAll()
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                for snap in snapshot {
                    print("DOKI: \(snap)")
                    if let postDict = snap.value as? Dictionary<String, AnyObject> {
                        let key = snap.key
                        let post = Produtos(postKey: key, postData: postDict)
                        self.produtos.append(post)
                    }
                }
            }
            
            //            self.historico.sort(by: {$0.data > $1.data})
            self.produtoTV.reloadData()
            //            self.carregandoV.isHidden = true
            //            self.indicadorAIV.stopAnimating()
        })
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return produtos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let post = produtos[indexPath.row]
        if let cell = tableView.dequeueReusableCell(withIdentifier: "ProdutoCell") as? ProdutosTVC {
            cell.configureCell(produto: post.produto, value: post.value)
            return cell
        } else {
            return ProdutosTVC()
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    @IBAction func incluirBtnPressed(_ sender: RoundedButton) {
        let inc_produto = DataService.ds.REF_PRODUTO.childByAutoId()
        
        inc_produto.child("produto").setValue(produtoLbl.text)
        let cost2 = (self.valorLbl.text! as NSString).doubleValue
        inc_produto.child("value").setValue(cost2)
        excluirBtn.isEnabled = false
        produtoLbl.text = ""
        valorLbl.text = ""
    }
    
    @IBAction func excluirBtnPressed(_ sender: RoundedButton) {
        let refreshAlert = UIAlertController(title: "Exclusão", message: "Confirma a exclusão do produto \(produtoLbl.text!)", preferredStyle: UIAlertControllerStyle.alert)
        
        refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
            let ref = DataService.ds.REF_PRODUTO.child(self.prd_postkey)
            
            ref.removeValue { error, _ in
                
                print(error)
            }
            self.produtoTV.reloadData()
        }))
        
        refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
            print("Handle Cancel Logic here")
        }))
        
        present(refreshAlert, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        excluirBtn.isEnabled = true
        produtoLbl.text = produtos[indexPath.row].produto
        valorLbl.text = "\(String(format: "%.2f", produtos[indexPath.row].value))"
        prd_postkey = produtos[indexPath.row].postKey
    }
}
