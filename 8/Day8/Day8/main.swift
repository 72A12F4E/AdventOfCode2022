struct Tree {
    let height: Int
    var isVisible: Bool
    private(set) var northScore: Int = 1
    private(set) var southScore: Int = 1
    private(set) var eastScore: Int = 1
    private(set) var westScore: Int = 1
    
    var totalScore: Int {
        northScore * southScore * eastScore * westScore
    }
    
    mutating func setScore(_ score: Int, for direction: Direction) {
        switch direction {
        case .north:
            self.northScore = score
        case .south:
            self.southScore = score
        case .east:
            self.eastScore = score
        case .west:
            self.westScore = score
        }
    }
}

enum Direction: CaseIterable {
    case north
    case south
    case east
    case west
    
    var isNorthSouth: Bool {
        self == .north || self == .south
    }
    
    var isEastWest: Bool {
        self == .east || self == .west
    }
}

func parseInput(_ input: String) -> [[Tree]] {
    var grid: [[Tree]] = []
    let split = input.split(separator: "\n").map(Array.init)
    let height = split.count
    let width = split[0].count
    for rowIndex in 0..<split.count {
        grid.append([])
        for colIndex in 0..<split[rowIndex].count {
            grid[rowIndex].append(
                Tree(
                    height: Int(exactly: split[rowIndex][colIndex].wholeNumberValue!)!,
                    isVisible: rowIndex == 0 ||
                        rowIndex == height - 1 ||
                        colIndex == 0 ||
                        colIndex == width - 1
                )
            )
        }
    }
    return grid
}

func traverse(_ trees: inout [[Tree]], row: Int, column: Int, direction: Direction) {
    let route: Array = {
        switch direction {
        case .north:
            return Array(0..<row).reversed()
        case .south:
            return Array((row + 1)..<trees[row].count)
        case .east:
            return Array(0..<column).reversed()
        case .west:
            return Array((column + 1)..<trees.count)
        }
    }()
    
    let currentTree = trees[row][column]
    var score = 1
    var flag = true
    for look in route {
        let row = direction.isNorthSouth ? look : row
        let column = direction.isEastWest ? look : column
        if trees[row][column].height >= currentTree.height {
            flag = false
            break
        }
        score += 1
    }
    if flag {
        trees[row][column].isVisible = true
    }
    trees[row][column].setScore(score, for: direction)
}

func updateVisibility(_ trees: inout [[Tree]]) {
    let height = trees.count
    let width = trees[0].count
    for rowIndex in 0..<height {
        for colIndex in 0..<width {
            Direction.allCases.forEach { direction in
                traverse(&trees, row: rowIndex, column: colIndex, direction: direction)
            }
        }
    }
}

var trees = parseInput(input)
updateVisibility(&trees)

// Display trees
var counter = 0
var visibilityOutput = ""
var heightOutput = ""
for row in trees {
    for tree in row {
        heightOutput += "\(tree.height)"
        if tree.isVisible {
            visibilityOutput += "*"
            counter += 1
        } else {
            visibilityOutput += " "
        }
    }
    visibilityOutput += "\n"
    heightOutput += "\n"
}

print(heightOutput)
print(visibilityOutput)
print(counter) // Part 1 solution

var maxViewing = 1
for (rowIndex, row) in trees.enumerated() {
    for (colIndex, tree) in row.enumerated() {
        if tree.totalScore > maxViewing {
            print("new max score at (\(rowIndex), \(colIndex)): \(tree.totalScore) = \(tree.northScore) * \(tree.southScore) * \(tree.eastScore) * \(tree.westScore)")
            maxViewing = tree.totalScore
        }
    }
}
