//
//  ListRouter.swift
//  marvel-app
//
//  Created by Fabrizio Sposetti on 18/05/2022.
//

import UIKit

protocol Router {
    func route(to routeId: String, from context: UIViewController, parameters: Any?)
}

class ListRouter: Router {

    func route(to routeId: String, from context: UIViewController, parameters: Any?) {
        guard let route = ListViewController.Route(rawValue: routeId) else { return }
        switch route {
        case .characterDetail:
            if let characterDetailVc: DetailViewController = context.storyboard?
                .instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController,
               let detailInputView = parameters as? DetailInputView {
                characterDetailVc.detailInputView = detailInputView
                context.navigationController?.pushViewController(characterDetailVc, animated: true)
            }
        }
    }


}
