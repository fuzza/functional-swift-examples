//: [Previous](@previous)

import Foundation

struct Trie <Element: Hashable> {
    let isElement: Bool
    let children: [ Element : Trie <Element> ]
}

extension Trie {
    init() {
        self.isElement = false
        self.children = [:]
    }
}

extension Trie {
    var elements: [[Element]] {
        var result: [[Element]] = self.isElement ? [[]] : []
        for (key, value) in children {
            result += value.elements.map { [key] + $0 }
        }
        return result
    }
}

// Decompose helper 

extension Array {
    var decompose: (Element, [Element])? {
        return isEmpty ? nil : (self[startIndex], Array(self.dropFirst()))
    }
}


func sum(_ xs:[Int]) -> Int {
    guard let (head, tail) = xs.decompose else { return 0 }
    return head + sum(tail)
}

let array = [12,1,6,3,2,5]
let arraySum = sum(array)

func qsort(_ xs:[Int]) -> [Int] {
    guard let (pivot, rest) = xs.decompose else { return [] }
    let lesser = rest.filter { $0 < pivot }
    let greater = rest.filter { $0 >= pivot }
    return qsort(lesser) + Array([pivot]) + qsort(greater)
}

let sortedArray = qsort(array)

// Lookup

extension Trie {
    func lookup(_ key: [Element]) -> Bool {
        guard let (head, tail) = key.decompose else { return isElement }
        guard let subtree = self.children[head] else { return false }
        return subtree.lookup(tail)
    }
}

extension Trie {
    func withPrefix(_ prefix: [Element]) -> Trie<Element>? {
        guard let (head, tail) = prefix.decompose else { return self }
        guard let remainder = children[head] else { return nil }
        return remainder.withPrefix(tail)
    }
}

extension Trie {
    func autocomplete(_ key: [Element]) -> [[Element]] {
        return self.withPrefix(key)?.elements ?? []
    }
}

extension Trie {
    init(_ key: [Element]) {
        if let (head, tail) = key.decompose {
            let children = [head : Trie(tail)]
            self = Trie(isElement: false, children: children)
        } else {
            self = Trie(isElement: true, children: [:])
        }
    }
}

extension Trie {
    func insert(_ key: [Element]) -> Trie<Element> {
        guard let (head, tail) = key.decompose else {
            return Trie(isElement: true, children: self.children)
        }
        
        var newChildren = children
        if let nextTrie = children[head] {
            newChildren[head] = nextTrie.insert(tail)
        } else {
            newChildren[head] = Trie(tail)
        }
        return Trie(isElement: true, children:newChildren)
    }
    
    mutating func insert1(_ key: [Element]) {
        guard let (head, tail) = key.decompose else {
            self = Trie(isElement: true, children: self.children)
            return
        }
        
        var newChildren = children
        if let nextTrie = children[head] {
            nextTrie.insert(tail)
            newChildren[head] = nextTrie
        } else {
            newChildren[head] = Trie(tail)
        }
        self = Trie(isElement: true, children:newChildren)
    }
    
}

func buildStringTrie(_ words: [String]) -> Trie<Character> {
    let emptyTrie = Trie<Character>()
    return words.reduce(emptyTrie) { trie, word in
        trie.insert(Array(word.characters))
    }
}

func autocompleteString(_ word: String, knownWords:Trie<Character>) -> [String] {
    let chars = Array(word.characters)
    let completed = knownWords.autocomplete(chars)
    return completed.map {
        return word + String(describing: $0)
    }
}

let contents = ["cart", "car", "cat", "dog"]
let trie = buildStringTrie(contents)
let completions = autocompleteString("car", knownWords: trie)


//: [Next](@next)
