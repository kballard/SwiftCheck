//
//  Modifiers.swift
//  SwiftCheck-iOS
//
//  Created by Robert Widmann on 1/29/15.
//  Copyright (c) 2015 CodaFi. All rights reserved.
//


/// For types that either do not have a Printable instance or that wish to have no description to
/// print, Blind will create a default description for them.
public struct Blind<A : Arbitrary> : Arbitrary, Printable {
	public let getBlind : A
	
	public init(_ blind : A) {
		self.getBlind = blind
	}
	
	public var description : String {
		return "(*)"
	}
	
	private static func create(blind : A) -> Blind<A> {
		return Blind(blind)
	}
	
	public static func arbitrary() -> Gen<Blind<A>> {
		return A.arbitrary().fmap(Blind.create)
	}
	
	public static func shrink(bl : Blind<A>) -> [Blind<A>] {
		return A.shrink(bl.getBlind).map(Blind.create)
	}
}

public func == <T : protocol<Arbitrary, Equatable>>(lhs : Blind<T>, rhs : Blind<T>) -> Bool {
	return lhs.getBlind == rhs.getBlind
}

/// Guarantees test cases for its underlying type will not be shrunk.
public struct Static<A : Arbitrary> : Arbitrary, Printable {
	public let getStatic : A
	
	public init(_ fixed : A) {
		self.getStatic = fixed
	}
	
	public var description : String {
		return "Static( \(self.getStatic) )"
	}
	
	private static func create(blind : A) -> Static<A> {
		return Static(blind)
	}
	
	public static func arbitrary() -> Gen<Static<A>> {
		return A.arbitrary().fmap(Static.create)
	}
	
	public static func shrink(bl : Static<A>) -> [Static<A>] {
		return []
	}
}

public func == <T : protocol<Arbitrary, Equatable>>(lhs : Static<T>, rhs : Static<T>) -> Bool {
	return lhs.getStatic == rhs.getStatic
}

/// Generates an array of arbitrary values of type A.
public struct ArrayOf<A : Arbitrary> : Arbitrary, Printable {
	public let getArray : [A]

	public init(_ array : [A]) {
		self.getArray = array
	}

	public var description : String {
		return "\(self.getArray)"
	}

	private static func create(array : [A]) -> ArrayOf<A> {
		return ArrayOf(array)
	}

	public static func arbitrary() -> Gen<ArrayOf<A>> {
		return sized { n in
			return choose((0, n)).bind { k in
				if k == 0 {
					return Gen.pure(ArrayOf([]))
				}

				return sequence(Array((0...k)).map { _ in A.arbitrary() }).fmap(ArrayOf.create)
			}
		}
	}

	public static func shrink(bl : ArrayOf<A>) -> [ArrayOf<A>] {
		if bl.getArray.isEmpty {
			return []
		} else if bl.getArray.count == 1 {
			let hd = bl.getArray[0]
			return [ ArrayOf([]) ] + [ ArrayOf(A.shrink(hd)) ]
		}
		let x = bl.getArray[0]
		let xs = Array<A>(bl.getArray[1..<bl.getArray.count])
		return [ ArrayOf<A>(xs) ] + ArrayOf<A>.shrink(ArrayOf<A>(xs)) + ArrayOf<A>.shrink(ArrayOf<A>(A.shrink(x) + xs))
	}
}

public func == <T : protocol<Arbitrary, Equatable>>(lhs : ArrayOf<T>, rhs : ArrayOf<T>) -> Bool {
	return lhs.getArray == rhs.getArray
}

/// Generates an Optional of arbitrary values of type A.
public struct OptionalOf<A : Arbitrary> : Arbitrary, Printable {
	public let getOptional : A?

	public init(_ opt : A?) {
		self.getOptional = opt
	}

	public var description : String {
		return "\(self.getOptional)"
	}

	private static func create(opt : A?) -> OptionalOf<A> {
		return OptionalOf(opt)
	}

	public static func arbitrary() -> Gen<OptionalOf<A>> {
		return frequency([(1, Gen.pure(OptionalOf(Optional<A>.None))), (3, liftM({ OptionalOf(Optional<A>.Some($0)) })(m1: A.arbitrary()))])
	}

	public static func shrink(bl : OptionalOf<A>) -> [OptionalOf<A>] {
		if let x = bl.getOptional {
			return [OptionalOf(Optional<A>.None)] + A.shrink(x).map({ OptionalOf(Optional<A>.Some($0)) })
		}
		return []
	}
}

public func == <T : protocol<Arbitrary, Equatable>>(lhs : OptionalOf<T>, rhs : OptionalOf<T>) -> Bool {
	return lhs.getOptional == rhs.getOptional
}


/// Guarantees that every generated integer is greater than 0.
public struct Positive<A : protocol<Arbitrary, SignedNumberType>> : Arbitrary, Printable {
	public let getPositive : A
	
	public init(_ pos : A) {
		self.getPositive = pos
	}
	
	public var description : String {
		return "Positive( \(self.getPositive) )"
	}
	
	private static func create(blind : A) -> Positive<A> {
		return Positive(blind)
	}
	
	public static func arbitrary() -> Gen<Positive<A>> {
		return A.arbitrary().fmap({ Positive.create(abs($0)) }).suchThat({ $0.getPositive > 0 })
	}
	
	public static func shrink(bl : Positive<A>) -> [Positive<A>] {
		return A.shrink(bl.getPositive).filter({ $0 > 0 }).map({ Positive($0) })
	}
}

public func == <T : protocol<Arbitrary, SignedNumberType>>(lhs : Positive<T>, rhs : Positive<T>) -> Bool {
	return lhs.getPositive == rhs.getPositive
}

/// Guarantees that every generated integer is never 0.
public struct NonZero<A : protocol<Arbitrary, IntegerType>> : Arbitrary, Printable {
	public let getNonZero : A
	
	public init(_ non : A) {
		self.getNonZero = non
	}
	
	public var description : String {
		return "NonZero( \(self.getNonZero) )"
	}
	
	private static func create(blind : A) -> NonZero<A> {
		return NonZero(blind)
	}
	
	public static func arbitrary() -> Gen<NonZero<A>> {
		return A.arbitrary().suchThat({ $0 != 0 }).fmap(NonZero.create)
	}
	
	public static func shrink(bl : NonZero<A>) -> [NonZero<A>] {
		return A.shrink(bl.getNonZero).filter({ $0 != 0 }).map({ NonZero($0) })
	}
}

public func == <T : protocol<Arbitrary, IntegerType>>(lhs : NonZero<T>, rhs : NonZero<T>) -> Bool {
	return lhs.getNonZero == rhs.getNonZero
}

/// Guarantees that every generated integer is greater than or equal to 0.
public struct NonNegative<A : protocol<Arbitrary, IntegerType>> : Arbitrary, Printable {
	public let getNonNegative : A
	
	public init(_ non : A) {
		self.getNonNegative = non
	}
	
	public var description : String {
		return "NonNegative( \(self.getNonNegative) )"
	}
	
	private static func create(blind : A) -> NonNegative<A> {
		return NonNegative(blind)
	}
	
	public static func arbitrary() -> Gen<NonNegative<A>> {
		return A.arbitrary().suchThat({ $0 >= 0 }).fmap(NonNegative.create)
	}
	
	public static func shrink(bl : NonNegative<A>) -> [NonNegative<A>] {
		return A.shrink(bl.getNonNegative).filter({ $0 >= 0 }).map({ NonNegative($0) })
	}
}

public func == <T : protocol<Arbitrary, IntegerType>>(lhs : NonNegative<T>, rhs : NonNegative<T>) -> Bool {
	return lhs.getNonNegative == rhs.getNonNegative
}
