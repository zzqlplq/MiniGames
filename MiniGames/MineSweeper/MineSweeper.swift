//
//  MineSweeper.swift
//  MiniGames
//
//  Created by zhengzhiqiang on 2022/4/6.
//

import Foundation

protocol Limitable {
    associatedtype WrapperType
    static var min: WrapperType { get set }
    static var max: WrapperType { get set }
    var isBeyond: Bool { get }
}


extension IndexPath : Limitable {
    
    static var min: IndexPath = IndexPath(row: 0, section: 0)
    static var max: IndexPath = IndexPath(row: Int.max, section: Int.max)
    public var isBeyond: Bool {
        return !((section >= IndexPath.min.section && row >= IndexPath.min.row) && (section <= IndexPath.max.section && row <= IndexPath.max.row))
    }
    
    func around() -> [IndexPath] {
        let topLeft = IndexPath(row: row - 1, section: section - 1), top = IndexPath(row: row, section: section - 1), topRight = IndexPath(row: row + 1, section: section - 1)
        let left = IndexPath(row: row - 1, section: section), right = IndexPath(row: row + 1, section: section)
        let bottomLeft = IndexPath(row: row - 1, section: section + 1), bottom = IndexPath(row: row, section: section + 1), bottomRight = IndexPath(row: row + 1, section: section + 1)
        return [topLeft, top, topRight, left, right, bottomLeft, bottom, bottomRight].filter{!$0.isBeyond}
    }
}


struct MineSweeperHandler {

    struct MineItem {
        enum MineState {
            case with
            case without
        }
        enum MarkState {
            case unmark
            case undetermined
            case mine
        }
        var state: MineState = .without
        var mark: MarkState = .unmark
        var selected = false
        var around = 0
    }

    private var allMines: [[MineItem]]
    private var mineCount: Int = 0
    
    init(sections: Int, rows: Int) {
        IndexPath.max = IndexPath(row: rows - 1, section: sections - 1)

        var all: [[MineItem]] = []
        (0..<sections).forEach { section in
            var sMines: [MineItem] = []
            (0..<rows).forEach { row in
                sMines.append(MineItem())
            }
            all.append(sMines)
        }
        allMines = all
    }
        
    subscript (indexPath: IndexPath) -> MineItem {
        get {
            return self.allMines[indexPath.section][indexPath.row]
        }
        set {
            self.allMines[indexPath.section][indexPath.row] = newValue
        }
    }
    
    
    mutating func createRadomMines(total: Int) {
        mineCount = total
        var temp = total
        while temp > 0 {
            let radomSection = Int.random(in: 0...IndexPath.max.section)
            let radomRow = Int.random(in: 0...IndexPath.max.row)
            let radomIndex = IndexPath(row: radomRow, section: radomSection)
            
            if  self[radomIndex].state != .with {
                self[radomIndex].state = .with
                temp -= 1
            }
        }
        
        for s in 0...IndexPath.max.section {
            for r in 0...IndexPath.max.row {
                let index = IndexPath(row:r , section: s)
                self[index].around = self.calcAroundMineCount(at: index)
            }
        }
    }
    
  
    mutating func selected(at index: IndexPath) -> Bool {
        guard self[index].state == .without else { return false }

        self.iterateSelect(at: index)
        return true
    }
    
    func checkFinished() -> Bool {
        var remain = 0
        self.allMines.forEach { mineSections in
            mineSections.forEach { mine in
                if !mine.selected {
                    remain += 1
                }
            }
        }
        return mineCount == remain
    }

    
    private mutating func iterateSelect(at index: IndexPath) {
        
        guard !self[index].selected else { return }
        
        self[index].selected = true
        
        if self[index].around == 0 {
            index.around().forEach { iterateSelect(at: $0) }
        }
    }
    
    
    private func calcAroundMineCount(at index: IndexPath) -> Int {
        var count = 0
        index.around().forEach { i in
            if self[i].state == .with {
                count += 1
            }
        }
        return count
    }
    
}
