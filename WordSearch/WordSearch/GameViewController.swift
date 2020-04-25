import UIKit

protocol GameViewDelegate: class {
    func renderUI()
    func redrawGrid()
    func reloadGameIfNeeded()
}

class GameViewController: UIViewController {
    @IBOutlet var sourceLanguageLabel: UILabel!
    @IBOutlet var targetLanguageLabel: UILabel!
    @IBOutlet var sourceWordLabel: UILabel!
    @IBOutlet var collectionView: UICollectionView!
    
    var viewModel: GameViewModel?
    
    static func instance(_ viewModel: GameViewModel) -> GameViewController {
        let storyboard = UIStoryboard(name: Constants.entryStoryboardName, bundle: nil)
        guard let viewController = storyboard.instantiateViewController(identifier: Constants.gameViewControllerIdentifier) as? GameViewController else {
            fatalError()
        }
        
        viewController.viewModel = viewModel
        return viewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureCollectionView()
        startGame()
    }
    
    fileprivate func startGame() {
        viewModel?.randomPickGrid()
    }
    
    fileprivate func configureCollectionView() {
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(guessWordProcess))
        collectionView.addGestureRecognizer(panRecognizer)
        viewModel?.delegate = self
        collectionView.dataSource = self
    }
    
    fileprivate func presentSuccessAlert() {
        guard let viewModel = viewModel else {
            return
        }
        
        let alertViewController = UIAlertController(title: Constants.congratesTitle,
                                                    message: String(format: Constants.congratesMessage, viewModel.targetWord),
                                                    preferredStyle: .alert)
        alertViewController.addAction(UIAlertAction(title: Constants.congratesNext,
                                                    style: .default,
                                                    handler: { (_) in
            self.dismiss(animated: true, completion: nil)
            self.viewModel?.randomPickGrid()
        }))
        present(alertViewController, animated: true, completion: nil)
    }
}

extension GameViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let row = viewModel?.row,
            let col = viewModel?.col else {
                return 0
        }
        
        return row * col
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.gameCellIdentifier, for: indexPath) as? GameCollectionViewCell,
            let selectedGrid = viewModel?.selectedGrid,
            let row = viewModel?.row,
            let col = viewModel?.col else {
            return UICollectionViewCell()
        }

        cell.configure(selectedGrid.characterGrid[indexPath.item / row][indexPath.item % col])
        
        if let validWordLocation = viewModel?.validWordLocation {
            if validWordLocation.contains(where: {
                $0.column == indexPath.item % col && $0.row == indexPath.item / row
            }) {
                cell.highlightCell()
            } else {
                cell.unhighlightCell()
            }
        }
        
        return cell
    }
}

extension GameViewController: GameViewDelegate {
    func renderUI() {
        sourceLanguageLabel.text = String(format: Constants.sourceLanguage, viewModel?.selectedGrid?.sourceLanguage ?? "")
        targetLanguageLabel.text = String(format: Constants.targetLanguage, viewModel?.selectedGrid?.targetLanguage ?? "")
        sourceWordLabel.text = String(format: Constants.sourceWord, viewModel?.selectedGrid?.word ?? "")
        redrawGrid()
    }
    
    func redrawGrid() {
        guard let col = viewModel?.col else {
            return
        }
        
        collectionView.collectionViewLayout =
            GameCollectionViewColumnFlowLayout(cellsPerRow: col,
                                               minimumInteritemSpacing: CGFloat(Constants.cellSpace),
                                               minimumLineSpacing: CGFloat(Constants.cellSpace),
                                               sectionInset: UIEdgeInsets(top: CGFloat(Constants.cellSpace),
                                                                          left: CGFloat(Constants.cellSpace),
                                                                          bottom: CGFloat(Constants.cellSpace),
                                                                          right: CGFloat(Constants.cellSpace)))
        collectionView.reloadData()
    }
    
    func reloadGameIfNeeded() {
        guard let viewModel = viewModel else {
            return
        }
        
        if viewModel.isSuccess {
            presentSuccessAlert()
            viewModel.isSuccess = false
        }
    }
}

extension GameViewController {
    @objc func guessWordProcess(sender: UIPanGestureRecognizer) {
        if sender.state == .ended {
            viewModel?.validateWord()
            return
        }
        let location = sender.location(in: collectionView)
        
        guard let row = viewModel?.row,
            let col = viewModel?.col,
            location.y <= collectionView.contentSize.height
             else {
            return
        }
        
        guard let indexPath = collectionView.indexPathForItem(at: location) else {
            return
        }
        
        if sender.state == .began {
            viewModel?.beginPosition.row = indexPath.item / row
            viewModel?.beginPosition.column = indexPath.item % col
            viewModel?.updateValidWordIfNeeded(needClear: true)
        } else {
            viewModel?.endPosition.row = indexPath.item / row
            viewModel?.endPosition.column = indexPath.item % col
            viewModel?.updateValidWordIfNeeded(needClear: false)
        }
    }
}
