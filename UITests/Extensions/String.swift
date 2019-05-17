import XCTest

extension String {
    subscript (count: Int) -> Character {
        return self[index(startIndex, offsetBy: count)]
    }

    static func random(length: Int = 32, alphabet: String="ABCDEF0123456789") -> String {
        let upperBound = UInt32(alphabet.count)
        return String((0..<length).map { _ -> Character in
            alphabet[Int(arc4random_uniform(upperBound))]
        })
    }
}
