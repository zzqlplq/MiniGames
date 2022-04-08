//
//  MineSweeper.swift
//  MiniGames
//
//  Created by zhengzhiqiang on 2022/4/6.
//

import Foundation

enum MineState {
    case with
    case without
}


enum MarkState {
    case unmark
    case undetermined
    case sure
}


struct MineItem {
    var state: MineState = .without
    var mark: MarkState = .unmark
    var selected = false
    var around = 0
}


struct MineSweeperHandler {
    
    var allMines: [[MineItem]]
    let sections: Int
    let rows: Int
    
    init(sections: Int, rows: Int) {
        self.sections = sections
        self.rows = rows
        
        var all: [[MineItem]] = []
        for _ in 0..<sections {
            var mines: [MineItem] = []
            for _ in  0..<rows {
                mines += [MineItem()]
            }
             all += [mines]
        }
        allMines = all
    }

    mutating func markMine(mark: MarkState, section: Int, row: Int) {
        allMines[section][row].mark = mark;
    }
    
    mutating func createRadomMines(totalMines:Int) {
        var total = totalMines
        
        while total > 0 {
            let radomSection = Int.random(in: 0..<sections)
            let radomRow = Int.random(in: 0..<rows)
            
            var item = allMines[radomSection][radomRow]

            if  item.state != .with {
                item.state = .with
                total -= 1
                allMines[radomSection][radomRow] = item
            }
        }
    }
    
    mutating func selected(section: Int, row: Int) -> Bool {
        
        var item = self.allMines[section][row]
        if item.state == .with {
            return false
        }
        
        if !item.selected {
            item.around = self.calcMineAround(section: section, row: row)
            item.selected = true
        }
        self.allMines[section][row] = item
        return true
    }

    
    func calcMineAround(section: Int, row: Int) -> Int {
        let aroundIndexs = self.calcAround(section: section, row: row)
        var count = 0
        aroundIndexs.forEach { (s, r) in
            if self.allMines[s][r].state == .with {
                count += 1
            }
        }
        return count
    }
    
    
    func calcAround(section: Int, row: Int) -> [(Int, Int)] {
        
        let topLeft = (section - 1, row - 1), top = (section - 1, row), topRight = (section - 1, row + 1)
        let left = (section, row - 1), right = (section, row + 1)
        let bottomLeft = (section + 1, row - 1), bottom = (section +  1, row), bottomRight = (section + 1, row + 1)
    
        let around = [topLeft, top, topRight, left, right, bottomLeft, bottom, bottomRight]
        
        return around.filter { ($0 >= 0 && $1 >= 0) && ($0 < sections && $1 < rows)}
    }
    
    
}
