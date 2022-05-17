//
//  HeroTableViewCell.swift
//  marvel-app
//
//  Created by Fabrizio Sposetti on 16/05/2022.
//

import UIKit
import Kingfisher

class CharacterTableViewCell: UITableViewCell {
    
    // MARK: IBOutlets
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var characterImage: UIImageView!

    // MARK: Public
    static var identifier: String = "CharacterTableViewCell"

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func configure(name: String, thumbnail: String) {
        titleLbl.text = name
        setImageFrom(thumbnail)
    }

    private func setImageFrom(_ url: String) {
         let urlResource = URL(string: url)!
         let processor = DownsamplingImageProcessor(size: self.bounds.size)
         self.characterImage.kf.indicatorType = .activity
         self.characterImage.kf.setImage(
             with: urlResource,
             placeholder: UIImage(named: "character_placeholder"),
             options: [
                 .processor(processor),
                 .scaleFactor(UIScreen.main.scale),
                 .transition(.fade(1)),
                 .cacheOriginalImage
             ])
     }
    
}
