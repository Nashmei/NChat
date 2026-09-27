import Foundation

struct MatchResult {
    var cells: Set<Cell> = []
    var specials: [Cell: Special] = [:]
}

enum MatchEngine {
    static let size = 8

    static func freshBoard() -> [[Tile]] {
        var board = Array(
            repeating: Array(repeating: Tile(kind: .ruby), count: size),
            count: size
        )
        for row in 0..<size {
            for col in 0..<size {
                var choices = GemKind.allCases
                if col >= 2 && board[row][col - 1].kind == board[row][col - 2].kind {
                    choices.removeAll { $0 == board[row][col - 1].kind }
                }
                if row >= 2 && board[row - 1][col].kind == board[row - 2][col].kind {
                    choices.removeAll { $0 == board[row - 1][col].kind }
                }
                board[row][col] = Tile(kind: choices.randomElement() ?? .ruby)
            }
        }
        return board
    }

    static func adjacent(_ a: Cell, _ b: Cell) -> Bool {
        abs(a.row - b.row) + abs(a.col - b.col) == 1
    }

    static func matches(_ board: [[Tile]]) -> MatchResult {
        var result = MatchResult()

        for row in 0..<size {
            var start = 0
            while start < size {
                var end = start + 1
                while end < size && board[row][end].kind == board[row][start].kind { end += 1 }
                let count = end - start
                if count >= 3 {
                    for col in start..<end { result.cells.insert(Cell(row: row, col: col)) }
                    if count >= 5 {
                        result.specials[Cell(row: row, col: start + count / 2)] = .rainbow
                    } else if count == 4 {
                        result.specials[Cell(row: row, col: start + 1)] = .rowRocket
                    }
                }
                start = end
            }
        }

        for col in 0..<size {
            var start = 0
            while start < size {
                var end = start + 1
                while end < size && board[end][col].kind == board[start][col].kind { end += 1 }
                let count = end - start
                if count >= 3 {
                    for row in start..<end { result.cells.insert(Cell(row: row, col: col)) }
                    if count >= 5 {
                        result.specials[Cell(row: start + count / 2, col: col)] = .rainbow
                    } else if count == 4 {
                        result.specials[Cell(row: start + 1, col: col)] = .columnRocket
                    }
                }
                start = end
            }
        }

        for cell in result.cells {
            let horizontal =
                (cell.col > 0 && result.cells.contains(Cell(row: cell.row, col: cell.col - 1))) ||
                (cell.col < size - 1 && result.cells.contains(Cell(row: cell.row, col: cell.col + 1)))
            let vertical =
                (cell.row > 0 && result.cells.contains(Cell(row: cell.row - 1, col: cell.col))) ||
                (cell.row < size - 1 && result.cells.contains(Cell(row: cell.row + 1, col: cell.col)))
            if horizontal && vertical { result.specials[cell] = .bomb }
        }
        return result
    }

    static func expanded(_ initial: Set<Cell>, board: [[Tile]]) -> Set<Cell> {
        var clear = initial
        var queue = Array(initial)
        var seen = Set<Cell>()

        while let cell = queue.popLast() {
            guard !seen.contains(cell) else { continue }
            seen.insert(cell)

            switch board[cell.row][cell.col].special {
            case .rowRocket:
                for col in 0..<size {
                    let target = Cell(row: cell.row, col: col)
                    if clear.insert(target).inserted { queue.append(target) }
                }
            case .columnRocket:
                for row in 0..<size {
                    let target = Cell(row: row, col: cell.col)
                    if clear.insert(target).inserted { queue.append(target) }
                }
            case .bomb:
                for row in max(0, cell.row - 1)...min(size - 1, cell.row + 1) {
                    for col in max(0, cell.col - 1)...min(size - 1, cell.col + 1) {
                        let target = Cell(row: row, col: col)
                        if clear.insert(target).inserted { queue.append(target) }
                    }
                }
            case .rainbow:
                let kind = board[cell.row][cell.col].kind
                for row in 0..<size {
                    for col in 0..<size where board[row][col].kind == kind {
                        clear.insert(Cell(row: row, col: col))
                    }
                }
            case .none:
                break
            }
        }
        return clear
    }

    static func specialCombo(_ a: Cell, _ b: Cell, board: inout [[Tile]]) -> Set<Cell>? {
        let sa = board[a.row][a.col].special
        let sb = board[b.row][b.col].special
        guard sa != .none && sb != .none else { return nil }

        var clear = Set<Cell>([a, b])
        let rockets: Set<Special> = [.rowRocket, .columnRocket]

        if sa == .rainbow || sb == .rainbow {
            let rainbowCell = sa == .rainbow ? a : b
            let otherCell = sa == .rainbow ? b : a
            let otherSpecial = board[otherCell.row][otherCell.col].special
            let targetKind = board[otherCell.row][otherCell.col].kind

            for row in 0..<size {
                for col in 0..<size where board[row][col].kind == targetKind {
                    let p = Cell(row: row, col: col)
                    board[row][col].special = otherSpecial == .rainbow ? .rainbow : otherSpecial
                    clear.insert(p)
                }
            }
            clear.insert(rainbowCell)
            return expanded(clear, board: board)
        }

        if sa == .bomb && sb == .bomb {
            let centerRow = (a.row + b.row) / 2
            let centerCol = (a.col + b.col) / 2
            for row in max(0, centerRow - 2)...min(size - 1, centerRow + 2) {
                for col in max(0, centerCol - 2)...min(size - 1, centerCol + 2) {
                    clear.insert(Cell(row: row, col: col))
                }
            }
            return expanded(clear, board: board)
        }

        if (sa == .bomb && rockets.contains(sb)) || (sb == .bomb && rockets.contains(sa)) {
            let center = sa == .bomb ? a : b
            for row in max(0, center.row - 1)...min(size - 1, center.row + 1) {
                for col in 0..<size { clear.insert(Cell(row: row, col: col)) }
            }
            for col in max(0, center.col - 1)...min(size - 1, center.col + 1) {
                for row in 0..<size { clear.insert(Cell(row: row, col: col)) }
            }
            return expanded(clear, board: board)
        }

        if rockets.contains(sa) && rockets.contains(sb) {
            for col in 0..<size { clear.insert(Cell(row: a.row, col: col)) }
            for row in 0..<size { clear.insert(Cell(row: row, col: a.col)) }
            return expanded(clear, board: board)
        }

        return expanded(clear, board: board)
    }

    static func collapse(_ board: inout [[Tile]], clearing: Set<Cell>, specials: [Cell: Special]) {
        for col in 0..<size {
            var survivors: [Tile] = []
            for row in stride(from: size - 1, through: 0, by: -1) {
                if !clearing.contains(Cell(row: row, col: col)) {
                    survivors.append(board[row][col])
                }
            }
            while survivors.count < size {
                survivors.append(Tile(kind: GemKind.allCases.randomElement() ?? .ruby))
            }
            for row in 0..<size { board[size - 1 - row][col] = survivors[row] }
        }

        for (cell, special) in specials {
            board[min(size - 1, max(0, cell.row))][cell.col].special = special
        }
    }

    static func hasMove(_ board: [[Tile]]) -> Bool {
        var copy = board
        for row in 0..<size {
            for col in 0..<size {
                for delta in [(0, 1), (1, 0)] {
                    let nextRow = row + delta.0
                    let nextCol = col + delta.1
                    guard nextRow < size, nextCol < size else { continue }
                    copy[row][col] = board[nextRow][nextCol]
                    copy[nextRow][nextCol] = board[row][col]
                    if !matches(copy).cells.isEmpty { return true }
                    copy = board
                }
            }
        }
        return false
    }
}
