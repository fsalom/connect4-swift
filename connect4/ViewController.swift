//
//  ViewController.swift
//  connect4
//
//  Created by Fernando Salom Carratala on 19/7/22.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var currentChip: UIImageView!
    @IBOutlet weak var boardImage: UIImageView!
    @IBOutlet weak var startButton: UIButton!

    let heightCorrection: CGFloat = 5
    var slotHeight: CGFloat = 0
    let slotWidth: CGFloat = UIScreen.main.bounds.width / 9
    let correctionPositionX: CGFloat = 0
    var chipTemp: UIView!
    var chip: UIImageView!
    var chipIndicator: UIImageView!
    var rows = 6
    var columns = 7
    var speed: CGFloat = 400
    var board: [[Int]]!
    var isAnimating = false
    var gestureLastState: UIGestureRecognizer.State = .began
    var imageName = "chip1"

    override func viewDidLoad() {
        super.viewDidLoad()
        slotHeight = (boardImage.layer.bounds.height / 8)
        chip = UIImageView(frame: CGRect(x: 0, y: 0, width: slotWidth, height: slotWidth))
        chip.image = UIImage(named: getImageName())
        chip.layer.cornerRadius = slotWidth / 2
        chipIndicator = UIImageView(frame: CGRect(x: 0, y: -100, width: slotWidth, height: slotWidth))
        chipIndicator.image = UIImage(named: "arrowDown")
        currentChip.image = UIImage(named: getImageName())

        board = [[Int]](repeating: [Int](repeating: 0, count: self.rows), count: self.columns)

        addGesture()
    }

    func getImageName(toggle: Bool = false) -> String {
        if !toggle { return imageName }
        imageName = imageName == "chip1" ? "chip2" : "chip1"
        return imageName
    }

    func savePosition(for player: Int){
        let position = getColumnPosition()
        let x = position - 1
        let rows = board[x]
        for (index, value) in rows.enumerated() {
            if value == 0{
                board[x][index] = player
                break
            }
        }
    }

    func getRowPosition() -> Int {
        let position = getColumnPosition()
        let x = position - 1
        let rows = board[x]
        for (index, value) in rows.enumerated() {
            if value == 0{
                return index
            }
        }
        return 0
    }

    func addGesture(){
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(addAnnotationOnLongPress(gesture:)))
        startButton.addGestureRecognizer(longPressGesture)
    }

    func getColumnPosition() -> Int {
        var position = Int(self.chip.center.x  / self.slotWidth)
        if position == 0 { position = 1 }
        if position == 8 { position = 7 }
        return position
    }

    func getCenterPoint(with point: CGPoint) -> CGPoint {
        let position = getColumnPosition()
        let newX = CGFloat(position) * self.slotWidth + self.slotWidth / 2
        return CGPoint(x: newX, y: point.y)
    }

    func getPositionWithLimits(current position: CGPoint) -> CGPoint {
        let limitY = boardImage.frame.origin.y + self.slotHeight / 2
        var newPoint = position
        if newPoint.y > limitY {
            newPoint.y = limitY
        }
        return newPoint
    }

    func getDistanceToMove(from point: CGPoint) -> CGFloat{
        let margin = (slotHeight - slotWidth) / 2
        var correction = 0.0
        if slotHeight < slotWidth{
            correction = slotHeight / 2
        }
        let origin = point.y
        let firstSlot = UIScreen.main.bounds.height / 2 - (2 * slotHeight) - (6 * margin)
        let row = getRowPosition()
        let numSlots = CGFloat(5 - row)
        let slotDistance = numSlots * slotHeight - (2 * margin * numSlots) - correction
        let distance = firstSlot - origin + slotDistance
        return distance
    }

    func createChip(with distance: CGFloat){
        let view = UIImageView(frame: CGRect(x: 0, y: 0, width: self.slotWidth, height: self.slotWidth))
        view.image = UIImage(named: getImageName())
        view.layer.cornerRadius = self.slotWidth / 2
        view.center = self.chip.center
        view.frame.origin.y = distance
        self.view.addSubview(view)
        self.view.bringSubviewToFront(self.boardImage)
        self.currentChip.image = UIImage(named: self.getImageName(toggle: true))
    }

    @objc func addAnnotationOnLongPress(gesture: UILongPressGestureRecognizer) {
        let isLastStateIncompatibleWithEnded = gestureLastState == .began || gestureLastState == .ended || gesture.state == .changed
        let isLastStateIncompatibleWithChanged = gestureLastState == .ended
        if (gesture.state == .ended && isLastStateIncompatibleWithEnded) || (gesture.state == .changed && isLastStateIncompatibleWithChanged) || isAnimating {
            chip.removeFromSuperview()
            chipIndicator.removeFromSuperview()
            return
        }

        gestureLastState = gesture.state

        var point = gesture.location(in: self.contentView)
        point.y = point.y - 30
        switch gesture.state {
        case .began:
            let generator = UIImpactFeedbackGenerator(style: .heavy)
            generator.impactOccurred()
            self.view.addSubview(chipIndicator)
            chip.center = point
            chip.image = UIImage(named: getImageName())
            self.view.addSubview(chip)
            self.view.bringSubviewToFront(boardImage)
            chip.center = getPositionWithLimits(current: point)
            chip.center = self.getCenterPoint(with: point)
        case .changed:
            chip.center = getPositionWithLimits(current: point)
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0, options: .curveEaseInOut) {
                let pointIndicator = CGPoint(x: point.x, y: self.boardImage.frame.origin.y - self.slotWidth)
                self.chipIndicator.center = self.getCenterPoint(with: pointIndicator)
            } completion: { _ in }

        case .ended:
            isAnimating = true
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0, options: .curveEaseInOut) {
                self.chip.center = self.getCenterPoint(with: point)
            } completion: { finished in
                self.chipIndicator.removeFromSuperview()
            }

            let distance = self.chip.frame.origin.y + self.getDistanceToMove(from: self.chip.center)
            let duration = CGFloat(distance / speed)


            UIView.animate(withDuration: duration, delay: 0, options: .curveEaseIn) {
                self.chip.frame.origin.y = distance
            } completion: { finished in
                self.isAnimating = false
                self.savePosition(for: 1)
                self.createChip(with: distance)
                self.chip.removeFromSuperview()
            }
        case .cancelled:
            chip.removeFromSuperview()
            chipIndicator.removeFromSuperview()
        case .failed:
            print("failed")
        case .possible:
            print("possible")
        default:
            print(gesture.state)
            break
        }
    }

    @IBAction func startButtonPressed(_ sender: Any) {

    }


}

