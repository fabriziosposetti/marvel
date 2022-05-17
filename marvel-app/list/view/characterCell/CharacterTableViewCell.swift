//
//  HeroTableViewCell.swift
//  marvel-app
//
//  Created by Fabrizio Sposetti on 16/05/2022.
//

import UIKit

class CharacterTableViewCell: UITableViewCell {
    
    // MARK: IBOutlets
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var detailLbl: UILabel!
    @IBOutlet weak var characterImage: UIImageView!

    // MARK: Public
    static var identifier: String = "CharacterTableViewCell"

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func configure(name: String, description: String) {
        titleLbl.text = name
        detailLbl.text = description
    }
    
}
