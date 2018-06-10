//
//  ProdutosTVC.swift
//  FideliCash-Comerciante
//
//  Created by Carlos Doki on 10/06/18.
//  Copyright © 2018 Carlos Doki. All rights reserved.
//

import UIKit

class ProdutosTVC: UITableViewCell {

    @IBOutlet weak var produtoLbl: UILabel!
    @IBOutlet weak var valorLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configureCell(produto: String,  value: Double) {
        produtoLbl.text = produto
        valorLbl.text = "\(value)"
    }
    
}
