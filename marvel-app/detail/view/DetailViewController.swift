//
//  DetailViewController.swift
//  marvel-app
//
//  Created by Fabrizio Sposetti on 16/05/2022.
//

import UIKit
import Kingfisher

class DetailViewController: UIViewController {

    // MARK: Public
    var detailInputView: DetailInputView!

    // MARK: IBOutlets
    @IBOutlet weak var characterTitle: UILabel!
    @IBOutlet weak var characterImage: UIImageView!
    @IBOutlet weak var characterDescription: UILabel!

    // MARK: Private
    private var viewModel: DetailViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        initViewModel()
        setupView()
    }

    private func initViewModel() {
        viewModel = DetailViewModel()
    }

    private func setupView() {
        title = "NAV_BAR_DETAIL_TITLE".localized()
        characterTitle.text = detailInputView.character.name
        characterDescription.text = detailInputView.character.characterDescription.isEmpty ? "DESCRIPTION_NOT_FOUND".localized() :
        detailInputView.character.characterDescription
        loadImage()
    }

    private func loadImage() {
        guard let urlResource = URL(string: detailInputView.character.getStandarLargeUrlImage()) else { return }
        let processor = DownsamplingImageProcessor(size: self.view.bounds.size)
        characterImage.kf.setImage(
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
