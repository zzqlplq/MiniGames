//
//  MineSweeperViewController.swift
//  MiniGames
//
//  Created by zhengzhiqiang on 2022/4/6.
//

import UIKit

class MineSweeperViewController: UIViewController {
    
    let sections = 6
    let rows = 6
    lazy var sweeperHandler: MineSweeperHandler = MineSweeperHandler(sections: sections, rows: rows)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sweeperHandler.createRadomMines(total: 5)
        view.backgroundColor = .systemGroupedBackground
        makeSubviewsLayout()
    }

    func makeSubviewsLayout() {
        view.addSubview(collectionView)
        collectionView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        collectionView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        collectionView.widthAnchor.constraint(equalTo: collectionView.heightAnchor).isActive = true
    }
    
    
    func startNewGame() {
        sweeperHandler = MineSweeperHandler(sections: sections, rows: rows)
        sweeperHandler.createRadomMines(total: 5)
        collectionView.reloadData()
    }
    
    func successGame() {
        let alert = UIAlertController(title: "挑战成功", message: nil, preferredStyle: .alert)
        let action = UIAlertAction(title: "重新挑战", style: .default) { [unowned self] _ in
            startNewGame()
        }
        alert.addAction(action)
        present(alert, animated: true)
    }
    
    
    
    lazy var collectionView: UICollectionView = {
        var layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 1, left: 0, bottom: 1, right: 0)
        let height = (UIScreen.main.bounds.height/CGFloat(sections) - 0.5*CGFloat(sections))
        layout.itemSize = CGSize(width: height, height: height)
        layout.minimumLineSpacing = 0.5
        layout.minimumInteritemSpacing = 0.5
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.isScrollEnabled = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(MineCollectionViewCell.self, forCellWithReuseIdentifier: MineSweeperViewController.CellId)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .white
        return collectionView
    }()

}


extension MineSweeperViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return rows
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MineSweeperViewController.CellId, for: indexPath) as! MineCollectionViewCell
        cell.index = indexPath
        cell.bind(sweeperHandler[indexPath])
        cell.delegate = self
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
                
        let result = sweeperHandler.selected(at: indexPath)
        if result {
            collectionView.reloadData()
            if sweeperHandler.checkFinished() {
                successGame()
            }
        } else {
            let alert = UIAlertController(title: "挑战失败", message: "您踩到雷了！", preferredStyle: .alert)
            let action = UIAlertAction(title: "重新挑战", style: .default) { [unowned self] _ in
                startNewGame()
            }
            alert.addAction(action)
            present(alert, animated: true)
        }
    }    
}


extension MineSweeperViewController: MarkProtocol {
    
    func makeMark(_ index: IndexPath) {
        
        let controller = UIAlertController(title:nil , message: nil, preferredStyle: .actionSheet)
        let cancel = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        let removeMark = UIAlertAction(title: "取消标记", style: .default) { [unowned self] _ in
            self.sweeperHandler[index].mark = .unmark
            self.collectionView.reloadData()
        }
        let mineMark = UIAlertAction(title: "雷", style: .default) {[unowned self] _ in
            self.sweeperHandler[index].mark = .mine
            self.collectionView.reloadData()
        }
        let undeterminedMark = UIAlertAction(title: "不确定", style: .default) {[unowned self] _ in
            self.sweeperHandler[index].mark = .undetermined
            self.collectionView.reloadData()
        }
        controller.addActions([mineMark, undeterminedMark, removeMark, cancel])
        self.present(controller, animated: true)
    }
}



protocol MarkProtocol: NSObjectProtocol {
    func makeMark(_ index: IndexPath)
}

class MineCollectionViewCell: UICollectionViewCell {
    
    var mine: MineSweeperHandler.MineItem!
    var index: IndexPath!
    
    weak var delegate: MarkProtocol?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        makeSubviewsLayout()
        defaultConfig()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func makeSubviewsLayout() {
        contentView.backgroundColor = .init(white: 0, alpha: 0.2)
        contentView.addSubview(contentLab)
        contentView.addSubview(detailLab)
        contentLab.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        contentLab.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
        contentLab.heightAnchor.constraint(equalTo: contentView.heightAnchor).isActive = true
        contentLab.widthAnchor.constraint(equalTo: contentView.heightAnchor).isActive = true
        detailLab.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
        detailLab.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
    }
    
    func defaultConfig() {
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(doubleTapHandle))
        doubleTap.numberOfTapsRequired = 2
        contentView.addGestureRecognizer(doubleTap)
    }

    
    func bind(_ mine: MineSweeperHandler.MineItem) {
        self.mine = mine
        if mine.isSelected {
            if mine.around == 0 {
                contentView.backgroundColor = .init(white: 0, alpha: 0.1)
                contentLab.text = ""
            } else {
                contentLab.text = mine.around.description
                contentView.backgroundColor = .init(white: 0, alpha: 0.2)
            }
        } else {
            contentView.backgroundColor = .init(white: 0, alpha: 0.2)
            contentLab.text = ""
        }
        
        switch mine.mark {
        case .mine:
            detailLab.text = "*"
        case .undetermined:
            detailLab.text = "?"
        case .unmark:
            detailLab.text = ""
        }
    }
    

    @objc
    func doubleTapHandle() {
        guard !self.mine.isSelected else { return }
        if let delegate = delegate {
            delegate.makeMark(self.index)
        }
    }

    
    
    lazy var contentLab: UILabel = {
        var lab = UILabel()
        lab.textAlignment = .center
        lab.font = UIFont.systemFont(ofSize: 20)
        lab.translatesAutoresizingMaskIntoConstraints = false
        return lab
    }()
    
    lazy var detailLab: UILabel = {
        var lab = UILabel()
        lab.font = UIFont.systemFont(ofSize: 20)
        lab.textColor = .red
        lab.translatesAutoresizingMaskIntoConstraints = false
        return lab
    }()
    
}


extension MineSweeperViewController {
    fileprivate static let CellId = "cellId"
}


extension MineSweeperViewController {
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscape
    }
    override var shouldAutorotate: Bool {
        return true
    }
}


extension UIAlertController {
    
    func addActions(_ actions: [UIAlertAction]) {
        actions.forEach { [unowned self] in
            self.addAction($0)
        }
    }
}
