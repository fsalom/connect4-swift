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

        // 1. Set animation content mode

          animationView.contentMode = .scaleAspectFit

          // 2. Set animation loop mode

          animationView.loopMode = .loop

          // 3. Adjust animation speed

          animationView.animationSpeed = 0.5

          // 4. Play animation
          animationView.play()
    }
}

