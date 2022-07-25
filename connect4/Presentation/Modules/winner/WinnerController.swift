//
//  ViewController.swift
//  connect4
//
//  Created by Fernando Salom Carratala on 19/7/22.
//

import UIKit
import Lottie

class WinnerController: UIViewController {

    @IBOutlet weak var animationView: AnimationView!

    override func viewDidLoad() {
        super.viewDidLoad()
          animationView.contentMode = .scaleAspectFit
          animationView.loopMode = .loop
          animationView.animationSpeed = 0.5
          animationView.play()
    }
}

