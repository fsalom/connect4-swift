//
//  MenuController.swift
//  connect4
//
//  Created by Fernando Salom Carratala on 20/12/22.
//

import Foundation
import UIKit

class MenuController: UIViewController {
    var viewModel: MenuViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = MenuViewModel(router: MenuRouter(viewController: self))
        setupUI()
    }

    func setupUI(){
        
    }

    @IBAction func onStartPressed(_ sender: Any) {
        viewModel.router.goToGame()
    }
}
