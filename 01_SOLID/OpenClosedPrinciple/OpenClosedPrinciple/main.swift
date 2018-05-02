//
//  main.swift
//  OpenClosedPrinciple
//
//  Created by Tim Beals on 2018-02-05.
//  Copyright © 2018 Tim Beals. All rights reserved.
//

import Foundation

/*
 TIPS: 08/03/2018
 To make protocols generic, use associatedtype
 To get the associated type from a protocol you need to communicate a class that adopts from it:
 <SpecA: Specification> This will allow you to then check SpecA.T == whatever
 If you want to make the type of your class the same as the types in your properties (dependecny injection) perform type checks like the one above in your class declaration
 */




//Open-Close Principle: Classes should be OPEN for extension, but closed for modification.

enum Color {
    case blue
    case red
    case green
}

enum Size {
    case small
    case medium
    case large
}

class Product {
    
    var name: String
    var color: Color
    var size: Size
    
    init(name: String, color: Color, size: Size) {
        self.name = name
        self.color = color
        self.size = size
    }
}


//THIS IS AN INEFFECTIVE CLASS:
class ProductFilter {
    
    //ERROR: You want to create filters by any combination of size, color, and name BUT that will require a lot of duplication of code that you have already written. Instead of modifying our class, we should extend it.
    
    static func filterByColor(products: [Product], color: Color) -> [Product]? {
        
        var results = [Product]()
        
        for p in products {
            if p.color == color {
                results.append(p)
            }
        }
        return results.isEmpty ? nil : results
    }
    
    static func filterBySize(products: [Product], size: Size) -> [Product]? {

        var results = [Product]()

        for p in products {
            if p.size == size {
                results.append(p)
            }
        }
        return results.isEmpty ? nil : results
    }

    
    //you can imagine how tedious this will get...
}



//Specification, Enterprise Design
protocol Specification {
    associatedtype T
    func isSatisfied(item: T) -> Bool
}

protocol Filter {
    associatedtype T
    func filter<Spec: Specification>(items: [T], spec: Spec) -> [T]
    where Spec.T == T
}

class ColorSpecification: Specification {
    typealias T = Product //by setting this, the protocol method now has 'Product' for item instead of a generic.
    
    let color: Color
    init(color: Color) {
        self.color = color
    }
    
    func isSatisfied(item: Product) -> Bool {
        return item.color == color
    }
}

class SizeSpecification: Specification {
    typealias T = Product
    
    let size: Size
    init(size: Size) {
        self.size = size
    }
    
    func isSatisfied(item: Product) -> Bool {
        return item.size == self.size
    }
}

class AndSpecification<T, SpecA: Specification, SpecB: Specification> : Specification where SpecA.T == SpecB.T, T == SpecA.T {
    
    let first: SpecA
    let second: SpecB
    init(first: SpecA, second: SpecB) {
        self.first = first
        self.second = second
    }
    
    func isSatisfied(item: T) -> Bool {
        return first.isSatisfied(item: item) && second.isSatisfied(item: item)
    }
}


//Open to extension by virtue of inheritance, but closed for modification. You can make a better filter without touching the BetterFilter class because you can access the Filter and Specification protocols.
class BetterFilter: Filter {
    typealias T = Product
    
    func filter<Spec: Specification>(items: [Product], spec: Spec) -> [T] where BetterFilter.T == Spec.T {
        var result = [Product]()
        for i in items {
            if spec.isSatisfied(item: i) {
                result.append(i)
            }
        }
        return result
    }
}




let apple = Product(name: "apple", color: .green, size: .small)
let tree = Product(name: "tree", color: .green, size: .large)
let house = Product(name: "house", color: .blue, size: .large)

let allProducts = [apple, tree, house]

//USING THE BAD CLASS...
//let redProducts = ProductFilter.filterByColor(products: allProducts, color: .red)
//
//for p in redProducts! {
//    print(p.name)
//}

//MUCH BETTER!

let betterFilter = BetterFilter()

print("LARGE ONLY")

for p in betterFilter.filter(items: allProducts, spec: SizeSpecification(size: .large)) {
    print(p.name)
}

print("LARGE AND GREEN")

for p in betterFilter.filter(items: allProducts, spec: AndSpecification(first: SizeSpecification(size: .large), second: ColorSpecification(color: .green))) {
    print(p.name)
}



