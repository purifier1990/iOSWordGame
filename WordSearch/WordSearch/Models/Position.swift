/// The column and row of a cell within its grid.
struct Position: Codable {
    var column: Int
    var row: Int

    static func parse(_ coordinates: String) -> [Position] {
        coordinates
            .split(separator: ",")
            .map { Int($0)! }
            .chunked(2)
            .map { Position(column: $0[0], row: $0[1]) }
    }
}

extension Position: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.column == rhs.column && lhs.row == rhs.row
    }
}

private extension Array {
    func chunked(_ size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}
