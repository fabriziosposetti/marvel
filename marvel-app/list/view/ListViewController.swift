//
//  ViewController.swift
//  marvel-app
//
//  Created by Fabrizio Sposetti on 16/05/2022.
//

import UIKit
import RxSwift
import RxCocoa

class ListViewController: UIViewController {

    // MARK: IBOutlets
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!

    // MARK: Private
    private var viewModel: ListViewModel!
    private let disposeBag: DisposeBag! = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        initViewModel()
        loadCharcters()
    }

    private func loadCharcters() {
        viewModel.getCharacters()
    }

    private func initViewModel() {
        viewModel = ListViewModel()
        bindViewModel()
    }

    private func bindViewModel() {
        registerCell()
        bindTableView()
        bindLoading()
    }

    private func bindLoading() {
        viewModel.output.loading.bind(onNext: { [weak self] show in
            self?.handleProgress(show: show)
        }).disposed(by: disposeBag)
    }

    private func bindTableView() {
        viewModel.output.characters.bind(to: tableView.rx.items) { [weak self] (_, index, item: CharacterModel) in
            let identifier = CharacterTableViewCell.identifier
            guard let cell = self?.tableView.dequeueReusableCell(withIdentifier: identifier,
                                                                 for: IndexPath(index: index)) as? CharacterTableViewCell else {
                return UITableViewCell()
            }
            cell.configure(name: item.name, thumbnail: item.thumbnailUrl)
            return cell
        }.disposed(by: disposeBag)

        tableView.rx.willDisplayCell.subscribe(onNext: { [weak self] _, indexPath in
            guard let self = self else { return }
            let isLastCell = self.viewModel.isLastCell(row: indexPath.row)
            let hasNextPage = self.viewModel.hasNextPage()
            if isLastCell && hasNextPage {
                self.loadCharcters()
            }
        }).disposed(by: disposeBag)

    }

    private func registerCell() {
        tableView.register(UINib(nibName: CharacterTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: CharacterTableViewCell.identifier)
    }

    private func handleProgress(show: Bool) {
        if show {
            activityIndicator.isHidden = false
            activityIndicator.startAnimating()
        } else {
            activityIndicator.isHidden = true
            activityIndicator.stopAnimating()
        }
    }

}

