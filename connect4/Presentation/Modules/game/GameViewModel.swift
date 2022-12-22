//
//  MainViewModel.swift
//  connect4
//
//  Created by Fernando Salom Carratala on 23/7/22.
//

import UIKit

enum Player {
    case one
    case two

    var number: Int {
        switch self {
        case .one:
            return 1
        case .two:
            return 2
        }
    }
}

final class GameViewModel {
    var router: GameRouter
    var rows = 6
    var columns = 7
    var speed: CGFloat = 400
    var board: [[Int]]!
    var slotHeight: CGFloat = 0
    let slotWidth: CGFloat = UIScreen.main.bounds.width / 9
    let heightCorrection: CGFloat = 5
    let correctionPositionX: CGFloat = 0
    var player: Player = .one
    var imageName = "chip1"
    var boardImage: UIImageView!

    init(router: GameRouter){
        self.router = router
    }
    
    func viewReady(for boardView: UIImageView) {
        boardImage = boardView
        slotHeight = boardView.layer.bounds.height / 8
        board = [[Int]](repeating: [Int](repeating: 0, count: self.rows), count: self.columns)
    }

    func viewDidAppear() {
    }

}

extension GameViewModel {
    func changePlayer(){
        player = player == .one ? .two : .one
    }

    func getPositionWithLimits(current position: CGPoint) -> CGPoint {
        let limitY = boardImage.frame.origin.y + self.slotHeight / 2
        var newPoint = position
        newPoint.y = newPoint.y > limitY ? limitY : newPoint.y
        return newPoint
    }

    func getImageName(toggle: Bool = false) -> String {
        if !toggle { return imageName }
        imageName = imageName == "chip1" ? "chip2" : "chip1"
        return imageName
    }

    func getPlayerColor() -> UIColor {
        return imageName == "chip1" ? #colorLiteral(red: 0.9418870807, green: 0.632404983, blue: 0.2517617643, alpha: 1) : #colorLiteral(red: 0.8788487315, green: 0.1384550333, blue: 0.05413753539, alpha: 1)
    }

    func getPlayerName() -> String {
        let winnerRed =  NSLocalizedString("winner_red", comment: "Winner RED")
        let winnerYellow =  NSLocalizedString("winner_yellow", comment: "Winner YELLOW")
        return imageName == "chip1" ? winnerYellow :  winnerRed
    }
    
    func getRowPosition(_ centerX: CGFloat) -> Int {
        let position = getColumnPosition(centerX)
        let x = position - 1
        let rows = board[x]
        for (index, value) in rows.enumerated() {
            if value == 0{
                return index
            }
        }
        return 0
    }

    func getColumnPosition(_ centerX: CGFloat) -> Int {
        var position = Int(centerX  / slotWidth)
        if position == 0 { position = 1 }
        if position == 8 { position = 7 }
        return position
    }

    func getCenterPoint(with point: CGPoint, centerX: CGFloat) -> CGPoint {
        let position = getColumnPosition(centerX)
        let newX = CGFloat(position) * slotWidth + slotWidth / 2
        return CGPoint(x: newX, y: point.y)
    }
    
    func savePosition(centerX: CGFloat) {
        let x = getColumnPosition(centerX) - 1
        let y = getRowPosition(centerX)
        board[x][y] = player.number
    }

    func check() -> Bool{
        var numConnected = 0
        // COLUMN WINNER
        for x in 0...columns - 1 {
            for y in 0...rows - 1 {
                numConnected = board[x][y] == player.number ? numConnected + 1 : 0
                if numConnected == 4{
                    return true
                }
            }

        }

        // ROW WINNER
        numConnected = 0
        for y in 0...rows - 1 {
            for x in 0...columns - 1 {
                numConnected = board[x][y] == player.number ? numConnected + 1 : 0
                if numConnected == 4{
                    return true
                }
            }
        }

        // DIAGONAL WINNER
        for x in 0...columns - 1 {
            for y in 0...rows - 1 {
                if checkNext3(x: x, y: y) {
                    return true
                }
            }
        }
        return false
    }

    func checkNext3(x: Int, y: Int) -> Bool{
        if isInsideBoard(x: x, y: y, isAscending: true){
            if board[x][y] == player.number && board[x+1][y+1] == player.number && board[x+2][y+2] == player.number && board[x+3][y+3] == player.number {
                return true
            }
        }
        if isInsideBoard(x: x, y: y, isDescending: true){
            if board[x][y] == player.number && board[x+1][y-1] == player.number && board[x+2][y-2] == player.number && board[x+3][y-3] == player.number {
                return true
            }
        }
        return false
    }

    func isWinner() -> Bool {
        return check()
    }

    func isInsideBoard(x: Int, y: Int, isAscending: Bool = false, isDescending: Bool = false) -> Bool{
        var position = 0
        var isXOK = false
        var isYOK = false
        if isAscending {
            position = x + 3
            isXOK = position >= 0 && position <= columns && position <= rows ? true : false
            position = y + 3
            isYOK = position >= 0 && position <= columns && position <= rows ? true : false
            return isXOK && isYOK
        }
        if isDescending {
            position = x + 3
            isXOK = position >= 0 && position <= columns && position <= rows ? true : false
            position = y - 3
            isYOK = position >= 0 && position <= columns && position <= rows ? true : false
            return isXOK && isYOK
        }

        return false
    }
}
