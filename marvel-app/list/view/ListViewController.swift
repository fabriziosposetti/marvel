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
    @IBOutlet weak var tryAgainBtn: UIButton!
    @IBOutlet weak var footerActiviyIndicator: UIActivityIndicatorView!
    @IBOutlet weak var searchBtn: UIBarButtonItem!
    @IBOutlet weak var searchBar: UISearchBar!

    // MARK: Private
    private var viewModel: ListViewModel!
    private let disposeBag: DisposeBag! = DisposeBag()
    private var router: Router!

    enum Route: String {
        case characterDetail
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        initViewModel()
        initRouter()
        setupView()
        loadCharcters(showMidIndicator: true)
    }

    private func initViewModel() {
        viewModel = ListViewModel()
        bindViewModel()
    }

    private func initRouter() {
        router = ListRouter()
    }

    private func setupView() {
        title = "NAV_BAR_LIST_TITLE".localized()
        searchBar.showsCancelButton = true
        footerActiviyIndicator.isHidden = true
    }

    private func loadCharcters(showMidIndicator: Bool) {
        viewModel.getCharacters(showMidIndicator: showMidIndicator)
    }

    private func bindViewModel() {
        registerCell()
        bindTableView()
        bindLoading()
        bindError()
        bindSearchBar()
    }

    private func search(_ query: String?) {
        viewModel.search(query: query)
    }

    private func showInitialResults() {
        viewModel.showInitialResults()
    }

    private func bindSearchBar() {
        searchBar.rx.cancelButtonClicked.bind(onNext: { [weak self] in
            self?.searchBar.isHidden = true
            self?.showInitialResults()
        }).disposed(by: disposeBag)

        searchBar.rx.text
                    .orEmpty
                    .throttle(RxTimeInterval.seconds(1), scheduler: MainScheduler.instance)
                    .distinctUntilChanged()
                    .bind { [weak self] (query) in
                        if query.isEmpty {
                            self?.showInitialResults()
                        } else {
                            self?.search(query)
                        }
                    }.disposed(by: disposeBag)
    }

    private func bindLoading() {
        viewModel.output.loading.bind(onNext: { [weak self] show in
            guard let self = self else { return }
            self.handleMidIndicator(show: show)
        }).disposed(by: disposeBag)

        viewModel.output.loadingMoreCharacters.bind(onNext: { [weak self] show in
            guard let self = self else { return }
            self.handleFooterIndicator(show: show)
        }).disposed(by: disposeBag)
    }

    private func bindTableView() {
        viewModel.output.successfullyLoaded.bind(onNext: { [weak self] in
            guard let self = self else { return }
            self.showResults()
        }).disposed(by: disposeBag)

        viewModel.output.characters.bind(to: tableView.rx.items) { [weak self] (_, index, item: CharacterModel) in
            guard let self = self else { return UITableViewCell() }
            let identifier = CharacterTableViewCell.identifier
            guard let cell = self.tableView.dequeueReusableCell(withIdentifier: identifier,
                                                                for: IndexPath(index: index)) as? CharacterTableViewCell else {
                return UITableViewCell()
            }
            cell.configure(name: item.name, thumbnail: item.getLandscapeLargeUrlImage())
            return cell
        }.disposed(by: disposeBag)

        tableView.rx.willDisplayCell.subscribe(onNext: { [weak self] _, indexPath in
            guard let self = self else { return }
            let isLastCell = self.viewModel.isLastCell(row: indexPath.row)
            let hasNextPage = self.viewModel.hasNextPage()
            if isLastCell && hasNextPage {
                self.loadCharcters(showMidIndicator: false)
            }
        }).disposed(by: disposeBag)

        tableView.rx
            .modelSelected(CharacterModel.self)
            .subscribe(onNext: { [weak self] item in
                guard let self = self else { return }
                let detailInputView = DetailInputView(character: item)
                self.router.route(to: Route.characterDetail.rawValue, from: self, parameters: detailInputView)
            }).disposed(by: disposeBag)
    }

    private func showResults() {
        tryAgainBtn.isHidden = true
        tableView.isHidden = false
    }

    private func showErrorState() {
        handleMidIndicator(show: false)
        tryAgainBtn.isHidden = false
        showToast(message: "SERVICE_GENERIC_ERROR".localized(), successMsg: false)
    }

    private func bindError() {
        viewModel.output.error.subscribe(onNext: { [weak self] _ in
            guard let self = self else { return }
            self.showErrorState()
        }).disposed(by: disposeBag)
    }

    private func registerCell() {
        tableView.register(UINib(nibName: CharacterTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: CharacterTableViewCell.identifier)
    }

    private func handleMidIndicator(show: Bool) {
        if show {
            activityIndicator.isHidden = false
            activityIndicator.startAnimating()
        } else {
            footerActiviyIndicator.stopAnimating()
            footerActiviyIndicator.isHidden = true
            activityIndicator.isHidden = true
            activityIndicator.stopAnimating()
        }
    }

    private func handleFooterIndicator(show: Bool) {
        if show {
            footerActiviyIndicator.isHidden = false
            footerActiviyIndicator.startAnimating()
        } else {
            footerActiviyIndicator.stopAnimating()
            footerActiviyIndicator.isHidden = true
        }
    }

    @IBAction func tryAgainTapped(_ sender: Any) {
        tryAgainBtn.isHidden = true
        loadCharcters(showMidIndicator: true)
    }

    @IBAction func searchTapped(_ sender: Any) {
        searchBar.isHidden = false
    }

}

