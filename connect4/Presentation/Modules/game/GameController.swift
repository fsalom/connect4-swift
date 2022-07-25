import UIKit
import Lottie

class GameController: UIViewController {

    @IBOutlet weak var boardImage: UIImageView!
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var currentChip: UIImageView!
    @IBOutlet weak var startButton: UIButton!

    var viewModel: GameViewModel!
    
    var chipTemp: UIView!
    var chip: UIImageView!
    var chipIndicator: UIImageView!    
    var isAnimating = false
    var gestureLastState: UIGestureRecognizer.State = .began

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = GameViewModel(router: GameRouter(viewController: self))
        viewModel.viewReady(for: self.boardImage)
        setupUI()
        addGesture()
    }

    func setupUI(){
        chip = UIImageView(frame: CGRect(x: 0, y: 0, width: viewModel.slotWidth, height: viewModel.slotWidth))
        chip.image = UIImage(named: viewModel.getImageName())
        chip.layer.cornerRadius = viewModel.slotWidth / 2
        chipIndicator = UIImageView(frame: CGRect(x: 0, y: -100, width: viewModel.slotWidth, height: viewModel.slotWidth))
        chipIndicator.image = UIImage(named: "arrowDown")
        currentChip.image = UIImage(named: viewModel.getImageName())
        currentChip.layer.borderWidth = 4.0
        currentChip.layer.borderColor = UIColor.white.cgColor
        currentChip.layer.cornerRadius = currentChip.frame.width / 2
    }

    func addGesture(){
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(addAnnotationOnLongPress(gesture:)))
        startButton.addGestureRecognizer(longPressGesture)
    }

    func getDistanceToMove(from point: CGPoint) -> CGFloat{
        let margin = (viewModel.slotHeight - viewModel.slotWidth) / 2
        let correction = viewModel.slotHeight < viewModel.slotWidth ? viewModel.slotHeight / 2 : 0.0
        let origin = point.y
        let firstSlot = UIScreen.main.bounds.height / 2 - (2 * viewModel.slotHeight) - (6 * margin)
        let row = viewModel.getRowPosition(self.chip.center.x)
        let numSlots = CGFloat(5 - row)
        let slotDistance = numSlots * viewModel.slotHeight - (2 * margin * numSlots) - correction
        let distance = firstSlot - origin + slotDistance
        return distance
    }

    func createChip(with distance: CGFloat){
        let view = UIImageView(frame: CGRect(x: 0, y: 0, width: viewModel.slotWidth, height: viewModel.slotWidth))
        view.image = UIImage(named: viewModel.getImageName())
        view.layer.cornerRadius = viewModel.slotWidth / 2
        view.center = self.chip.center
        view.frame.origin.y = distance
        self.view.addSubview(view)
        self.view.bringSubviewToFront(self.boardImage)
        self.currentChip.image = UIImage(named: viewModel.getImageName(toggle: true))
        viewModel.changePlayer()
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
            chip.image = UIImage(named: viewModel.getImageName())
            self.view.addSubview(chip)
            self.view.bringSubviewToFront(boardImage)
            chip.center = viewModel.getPositionWithLimits(current: point)
            chip.center = viewModel.getCenterPoint(with: point, centerX: self.chip.center.x)
        case .changed:
            chip.center = viewModel.getPositionWithLimits(current: point)
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0, options: .curveEaseInOut) {
                let pointIndicator = CGPoint(x: point.x, y: self.boardImage.frame.origin.y - self.viewModel.slotWidth)
                self.chipIndicator.center = self.viewModel.getCenterPoint(with: pointIndicator, centerX: self.chip.center.x)
            } completion: { _ in }

        case .ended:
            isAnimating = true

            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0, options: .curveEaseInOut) {
                self.chip.center = self.viewModel.getCenterPoint(with: point, centerX: self.chip.center.x)
            } completion: { finished in
                self.chipIndicator.removeFromSuperview()
            }

            let distance = self.chip.frame.origin.y + self.getDistanceToMove(from: self.chip.center)
            let duration = CGFloat(distance / viewModel.speed)


            UIView.animate(withDuration: duration, delay: 0, options: .curveEaseIn) {
                self.chip.frame.origin.y = distance
            } completion: { finished in
                self.isAnimating = false
                self.viewModel.savePosition(centerX: self.chip.center.x)
                self.check()
                self.createChip(with: distance)
                self.chip.removeFromSuperview()
            }
        case .cancelled:
            chip.removeFromSuperview()
            chipIndicator.removeFromSuperview()
        default:
            break
        }
    }

    func check(){
        if viewModel.isWinner(){
            viewModel.router.showWinner()
        }
    }

}

