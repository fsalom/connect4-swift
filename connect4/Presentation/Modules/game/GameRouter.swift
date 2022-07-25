//
//  GameRouter.swift
//  connect4
//
//  Created by Fernando Salom Carratala on 25/7/22.
//

import Foundation
import UIKit


final class GameRouter {
    weak var viewController: UIViewController?

    init(viewController: UIViewController?) {
        self.viewController = viewController
    }

    func showWinner(){
        let storyboard = UIStoryboard(name: "WinnerView", bundle: nil)
        let winnnerController = storyboard.instantiateViewController(identifier: "WinnerView")

        if let presentationController = winnnerController.presentationController as? UISheetPresentationController {
            presentationController.detents = [.large()] /// change to [.medium(), .large()] for a half *and* full screen sheet
        }

        viewController?.present(winnnerController, animated: true)
    }
}
