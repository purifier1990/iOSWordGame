//
//  GameCollectionViewCell.swift
//  WordSearch
//
//  Created by wenyu zhao on 2020/4/10.
//  Copyright © 2020 Examplingo. All rights reserved.
//

import UIKit

class GameCollectionViewCell: UICollectionViewCell {
    @IBOutlet var characterLabel: UILabel!
    
    func configure(_ text: String) {
        self.characterLabel.text = text
    }
    
    func highlightCell() {
        backgroundColor = .systemBlue
    }
    
    func unhighlightCell() {
        backgroundColor = .systemGreen
    }
}
