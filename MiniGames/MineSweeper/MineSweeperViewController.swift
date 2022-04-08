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
    var sweeperHandler = MineSweeperHandler(sections: 6, rows: 6)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        makeSubviewsLayout()
        sweeperHandler.createRadomMines(totalMines: 5)
        view.backgroundColor = .systemGroupedBackground
    }

    func makeSubviewsLayout() {
        view.addSubview(collectionView)
        collectionView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        collectionView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        collectionView.widthAnchor.constraint(equalTo: collectionView.heightAnchor).isActive = true
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
        cell.bind(sweeperHandler.allMines[indexPath.section][indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
                
        let result = sweeperHandler.selected(section: indexPath.section, row: indexPath.row)
        if result {
            collectionView.reloadData()
        } else {
            print("踩到雷了")
        }
    }
    
}





class MineCollectionViewCell: UICollectionViewCell {
    
    var mine: MineItem!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        makeSubviewsLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

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
    
    func bind(_ mine: MineItem) {
        self.mine = mine
        contentLab.text = mine.selected ? mine.around.description : ""
        detailLab.text = mine.state == .with ? "*": ""
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
}
