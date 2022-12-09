//
//  main.swift
//  Day9
//
//  Created by Blake McAnally on 12/9/22.
//
import OrderedCollections
enum Direction: String, CustomStringConvertible {
    case up = "U"
    case down = "D"
    case left = "L"
    case right = "R"
    
    var description: String {
        self.rawValue
    }
    
    init?(_ direction: String) {
        switch direction {
        case "U":
            self = .up
        case "D":
            self = .down
        case "L":
            self = .left
        case "R":
            self = .right
        default:
            return nil
        }
    }
}

struct Command {
    var direction: Direction
    var count: Int
}

struct Point: Hashable {
    var x: Int
    var y: Int
    
    init(x: Int, y: Int) {
        self.x = x
        self.y = y
    }
    
    // Determines if the point is adjacent to the other point, including diagonally
    func isAdjacent(to other: Point) -> Bool {
        abs(x - other.x) <= 1 && abs(y - other.y) <= 1
    }
    
    // Makes a new point that is moved towards the `other` point
    func moved(towards other: Point) -> Point {
        guard !isAdjacent(to: other) else { return self }
        
        if x != other.x && y != other.y { // diagonal
            if abs(x - other.x) < abs(y - other.y) { // vertical
                return Point(x: other.x, y: {
                    if y < other.y {
                        return y + 1
                    } else {
                        return y - 1
                    }
                }())
            } else { // horizontal
                return Point(x: {
                    if x < other.x {
                        return x + 1
                    } else {
                        return x - 1
                    }
                }(), y: other.y)
            }
        } else if x != other.x {
            if other.x > x {
                return Point(x: x + 1, y: y)
            } else {
                return Point(x: x - 1, y: y)
            }
        } else if y != other.y {
            if other.y > y {
                return Point(x: x, y: y + 1)
            } else {
                return Point(x: x, y: y - 1)
            }
        } else {
            preconditionFailure("This shouldn't be possible because of the isAdjacent check")
        }
    }
}

func rotate90(_ array: [[String]]) -> [[String]] {
    var new = Array(
        repeating: Array(
            repeating: " ",
            count: array.count
        ),
        count: array.count
    )
    
    for i in 0..<array.count {
        for j in 0..<array.count {
            new[i][j] = array[j][array.count - i - 1]
        }
    }
    return new
}

func drawPoints(_ points: [Point]) -> String {
    let xMin = points.map(\.x).min()!
    let yMin = points.map(\.y).min()!
    let xMax = points.map(\.x).max()!
    let yMax = points.map(\.y).max()!
    let bounds = max(yMax - yMin, xMax - xMin) + 1
    var field = Array(
        repeating: Array(
            repeating: " ",
            count: bounds
        ),
        count: bounds
    )
    
    for point in points {
        field[point.x][point.y] = "#"
    }
    field[0][0] = "s"
    
    field = rotate90(field)
    
    var out = ""
    for row in field {
        for point in row {
            out.append(point)
        }
        out.append("\n")
    }
    return out
}

func parseCommands(_ input: String) -> [Command] {
    var commands: [Command] = []
    for line in input.split(separator: "\n") {
        let components = line.split(separator: " ")
        let command = Command(
            direction: Direction(String(components[0]))!,
            count: Int(components[1])!
        )
        commands.append(command)
    }
    return commands
}

func findVisitedPoints(_ commands: [Command]) -> [Point] {
    let start = Point(x: 0, y: 0)
    var visitedPoints: [Point] = [start]
    var head: Point = start
    var tail: Point = start
    for command in commands {
        for _ in 0..<command.count {
            // Move head
            switch command.direction {
            case .up:
                head.y += 1
            case .down:
                head.y -= 1
            case .left:
                head.x -= 1
            case .right:
                head.x += 1
            }
            // track tail
            visitedPoints.append(tail)
            
            // check if we need to move the tail
            if !tail.isAdjacent(to: head) {
                tail = tail.moved(towards: head)
            }
        }
    }
    
    return visitedPoints
}


let commands = parseCommands(hardInput)
let visited = OrderedSet(findVisitedPoints(commands))

//let xMin = visited.map(\.x).min()!
//let yMin = visited.map(\.y).min()!
//let xMax = visited.map(\.x).max()!
//let yMax = visited.map(\.y).max()!
//let bounds = max(yMax - yMin, xMax - xMin) + 1
//for index in 1..<visited.count {
//    let soFar = Array(visited[0..<index])
//    print(soFar.last!)
//    print(drawPoints(soFar))
//}
print(Set(visited).count)
