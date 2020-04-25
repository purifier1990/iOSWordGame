//
//  GameViewModel.swift
//  WordSearch
//
//  Created by wenyu zhao on 2020/4/10.
//  Copyright © 2020 Examplingo. All rights reserved.
//

class GameViewModel {
    let candidates: [Grid]
    var selectedGrid: Grid? {
        didSet {
            delegate?.renderUI()
        }
    }
    var row: Int? {
        get {
            return selectedGrid?.characterGrid.count
        }
    }
    var col: Int? {
        get {
            return selectedGrid?.characterGrid.first?.count
        }
    }
    var targetWordLocation = [Position]()
    var targetWord = ""
    var guessWord = ""
    var beginPosition = Position(column: 0, row: 0)
    var endPosition = Position(column: 0, row: 0)
    var validWordLocation = [Position]() {
        didSet {
            delegate?.redrawGrid()
        }
    }
    var isSuccess = false {
        didSet {
            delegate?.reloadGameIfNeeded()
        }
    }
    
    weak var delegate: GameViewDelegate?
    
    init(candidates: [Grid]) {
        self.candidates = candidates
    }
    
    func randomPickGrid() {
        guard let selectedGrid = candidates.randomElement() else {
            return
        }
        
        self.selectedGrid = selectedGrid
        
        guard let locationString = selectedGrid.wordLocations.keys.first,
            let targetWordString = selectedGrid.wordLocations.values.first else {
            return
        }
        
        targetWordLocation = Position.parse(locationString)
        targetWord = targetWordString
    }
    
    func updateValidWordIfNeeded(needClear: Bool) {
        let startX = beginPosition.row
        let startY = beginPosition.column
        let endX = endPosition.row
        let endY = endPosition.column
        
        var validWordLocation = [Position]()
        if startX == endX {
            validWordLocation = Array(min(startY, endY)...max(startY, endY)).map {
                Position(column: $0, row: startX)
            }
        } else if startY == endY {
            validWordLocation = Array(min(startX, endX)...max(startX, endX)).map {
                Position(column: startY, row: $0)
            }
        }
        
        if !validWordLocation.isEmpty {
            self.validWordLocation = validWordLocation
        }
        
        if (needClear) {
            self.validWordLocation.removeAll()
        }
    }
    
    func validateWord() {
        if validWordLocation == targetWordLocation {
            self.validWordLocation.removeAll()
            isSuccess = true
        }
    }
}
