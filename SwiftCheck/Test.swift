//
//  Test.swift
//  SwiftCheck
//
//  Created by Robert Widmann on 7/31/14.
//  Copyright (c) 2015 TypeLift. All rights reserved.
//

// MARK: - Property Testing with SwiftCheck

/// Property Testing is a more static and expressive form of Test-Driven Development that emphasizes
/// the testability of program properties - A statement or invariant that can be proven to hold when
/// fed any number of arguments of a particular kind.  It is akin to Fuzz Testing but is made
/// significantly more powerful by the primitives in this framework.
///
/// A `Property` in SwiftCheck is more than just `true` and `false`, it is a value that is capable
/// of producing a framework type called `Prop`, which models individual test cases that themselves
/// are capable of passing or failing "in the small" with a `TestResult`.  For those familiar with
/// Protocol-Oriented Programming, lying at the heart of all of these types is a protocol called
/// `Testable` that provides any type a means of converting itself to a `Property`.  SwiftCheck
/// uses `Testable` early and often in functions and operators to enable a high level of nesting
/// of framework primitives and an even higher level of genericity in the interface.  By default
/// SwiftCheck provides `Testable` instances for `Bool`, `Property`, `Prop`, and several other
/// internal framework types.  Practically, this means any assertions you could make in `XCTest`
/// will work immediately with the framework.

// MARK: - Quantifiers

/// Below is the method all SwiftCheck properties are based on, `forAll`.  `forAll` acts as a
/// "Quantifier", i.e. a contract that serves as a guarantee that a property holds when the given
/// testing block returns `true` or truthy values, and fails when the testing block returns `false`
/// or falsy values.  The testing block is usually used with Swift's abbreviated block syntax and
/// requires type annotations for all value positions being requested.  For example,
///
///     + This is "Property Notation".  It allows you to give your properties a name and instructs SwiftCheck to test it.
///     |                                                                + This backwards arrow binds a property name and a property to each other.
///     |                                                                |
///     v                                                                v
///     property("The reverse of the reverse of an array is that array") <- forAll { (xs : [Int]) in
///	        return
///	            (xs.reverse().reverse() == xs) <?> "Reverse on the left"
/// 	        ^&&^
///	 	        (xs == xs.reverse().reverse()) <?> "Reverse on the right"
///     }
///
/// Why require types?  For one, Swift cannot infer the types of local variables because SwiftCheck
/// uses highly polymorphic testing primitives.  But, more importantly, types are required because
/// SwiftCheck uses them to select the appropriate `Gen`erators and shrinkers for each data type
/// automagically by default.  Those `Gen`erators and shrinkers are then used to create 100 random
/// test cases that are evaluated lazily to produce a final result.

// MARK: - Going Further

/// As mentioned before, SwiftCheck types do not exist in a bubble.  They are highly compositional
/// and flexible enough to express unique combinations and permutations of test types.  Below is a
/// purely illustrative example utilizing a significant portion of SwiftCheck's testing functions:
///
///     /// This method comes out of SwiftCheck's test suite.
///
///    `SetOf` is called a "Modifier Type".  To learn more about them see `Modifiers.swift`---+
///                                                                                           |
///                                                                                           v
///     property("Shrunken sets of integers don't always contain [] or [0]") <- forAll { (s : SetOf<Int>) in
///
///         /// This part of the property uses `==>`, or the "implication" combinator.  Implication
///         /// only executes the following block if the preceding expression returns true.  It can
///         /// be used to discard test cases that contain data you don't want to test with.
///         return (!s.getSet.isEmpty && s.getSet != Set([0])) ==> {
///
///             /// N.B. `shrinkArbitrary` is a internal method call that invokes the shrinker.
///             let ls = self.shrinkArbitrary(s).map { $0.getSet }
///             return (ls.filter({ $0 == [0] || $0 == [] }).count >= 1).whenFail {
///                 print("Oh noe!")
///             }
///         }
///     }.expectFailure.verbose
///       ^             ^
///       |             |
///       |             +--- The property will print EVERY generated test case to the console.
///       + --- We expect this property not to hold.
///
/// Testing is not limited to just these listed functions.  New users should check out our test
/// suite and the files `Gen.swift`, `Property.swift`, `Modifiers.swift`, and the top half of this
/// very file to learn more about the various parts of the SwiftCheck testing mechanism.

/// Converts a function into a universally quantified property using the default shrinker and
/// generator for that type.
@warn_unused_result
public func forAll<A : Arbitrary>(pf : (A throws -> Testable)) -> Property {
	return forAllShrink(A.arbitrary, shrinker: A.shrink, f: pf)
}

/// Converts a function into a universally quantified property using the default shrinker and
/// generator for 2 types.
@warn_unused_result
public func forAll<A : Arbitrary, B : Arbitrary>(pf : (A, B) throws -> Testable) -> Property {
	return forAll({ t in forAll({ b in try pf(t, b) }) })
}

/// Converts a function into a universally quantified property using the default shrinker and
/// generator for 3 types.
@warn_unused_result
public func forAll<A : Arbitrary, B : Arbitrary, C : Arbitrary>(pf : (A, B, C) throws -> Testable) -> Property {
	return forAll({ t in forAll({ b, c in try pf(t, b, c) }) })
}

/// Converts a function into a universally quantified property using the default shrinker and
/// generator for 4 types.
@warn_unused_result
public func forAll<A : Arbitrary, B : Arbitrary, C : Arbitrary, D : Arbitrary>(pf : (A, B, C, D) throws -> Testable) -> Property {
	return forAll({ t in forAll({ b, c, d in try pf(t, b, c, d) }) })
}

/// Converts a function into a universally quantified property using the default shrinker and
/// generator for 5 types.
@warn_unused_result
public func forAll<A : Arbitrary, B : Arbitrary, C : Arbitrary, D : Arbitrary, E : Arbitrary>(pf : (A, B, C, D, E) throws -> Testable) -> Property {
	return forAll({ t in forAll({ b, c, d, e in try pf(t, b, c, d, e) }) })
}

/// Converts a function into a universally quantified property using the default shrinker and
/// generator for 6 types.
@warn_unused_result
public func forAll<A : Arbitrary, B : Arbitrary, C : Arbitrary, D : Arbitrary, E : Arbitrary, F : Arbitrary>(pf : (A, B, C, D, E, F) throws -> Testable) -> Property {
	return forAll({ t in forAll({ b, c, d, e, f in try pf(t, b, c, d, e, f) }) })
}

/// Converts a function into a universally quantified property using the default shrinker and
/// generator for 7 types.
@warn_unused_result
public func forAll<A : Arbitrary, B : Arbitrary, C : Arbitrary, D : Arbitrary, E : Arbitrary, F : Arbitrary, G : Arbitrary>(pf : (A, B, C, D, E, F, G) throws -> Testable) -> Property {
	return forAll({ t in forAll({ b, c, d, e, f, g in try pf(t, b, c, d, e, f, g) }) })
}

/// Converts a function into a universally quantified property using the default shrinker and
/// generator for 8 types.
@warn_unused_result
public func forAll<A : Arbitrary, B : Arbitrary, C : Arbitrary, D : Arbitrary, E : Arbitrary, F : Arbitrary, G : Arbitrary, H : Arbitrary>(pf : (A, B, C, D, E, F, G, H) throws -> Testable) -> Property {
	return forAll({ t in forAll({ b, c, d, e, f, g, h in try pf(t, b, c, d, e, f, g, h) }) })
}

/// Given an explicit generator, converts a function to a universally quantified property using the
/// default shrinker for that type.
@warn_unused_result
public func forAll<A : Arbitrary>(gen : Gen<A>, pf : (A throws -> Testable)) -> Property {
	return forAllShrink(gen, shrinker: A.shrink, f: pf)
}

/// Given 2 explicit generators, converts a function to a universally quantified property using the
/// default shrinkers for those 2 types.
@warn_unused_result
public func forAll<A : Arbitrary, B : Arbitrary>(genA : Gen<A>, _ genB : Gen<B>, pf : (A, B) throws -> Testable) -> Property {
	return forAll(genA, pf: { t in forAll(genB, pf: { b in try pf(t, b) }) })
}

/// Given 3 explicit generators, converts a function to a universally quantified property using the
/// default shrinkers for those 3 types.
@warn_unused_result
public func forAll<A : Arbitrary, B : Arbitrary, C : Arbitrary>(genA : Gen<A>, _ genB : Gen<B>, _ genC : Gen<C>, pf : (A, B, C) throws -> Testable) -> Property {
	return forAll(genA, pf: { t in forAll(genB, genC, pf: { b, c in try pf(t, b, c) }) })
}

/// Given 4 explicit generators, converts a function to a universally quantified property using the
/// default shrinkers for those 4 types.
@warn_unused_result
public func forAll<A : Arbitrary, B : Arbitrary, C : Arbitrary, D : Arbitrary>(genA : Gen<A>, _ genB : Gen<B>, _ genC : Gen<C>, _ genD : Gen<D>, pf : (A, B, C, D) throws -> Testable) -> Property {
	return forAll(genA, pf: { t in forAll(genB, genC, genD, pf: { b, c, d in try pf(t, b, c, d) }) })
}

/// Given 5 explicit generators, converts a function to a universally quantified property using the
/// default shrinkers for those 5 types.
@warn_unused_result
public func forAll<A : Arbitrary, B : Arbitrary, C : Arbitrary, D : Arbitrary, E : Arbitrary>(genA : Gen<A>, _ genB : Gen<B>, _ genC : Gen<C>, _ genD : Gen<D>, _ genE : Gen<E>, pf : (A, B, C, D, E) throws -> Testable) -> Property {
	return forAll(genA, pf: { t in forAll(genB, genC, genD, genE, pf: { b, c, d, e in try pf(t, b, c, d, e) }) })
}

/// Given 6 explicit generators, converts a function to a universally quantified property using the
/// default shrinkers for those 6 types.
@warn_unused_result
public func forAll<A : Arbitrary, B : Arbitrary, C : Arbitrary, D : Arbitrary, E : Arbitrary, F : Arbitrary>(genA : Gen<A>, _ genB : Gen<B>, _ genC : Gen<C>, _ genD : Gen<D>, _ genE : Gen<E>, _ genF : Gen<F>, pf : (A, B, C, D, E, F) throws -> Testable) -> Property {
	return forAll(genA, pf: { t in forAll(genB, genC, genD, genE, genF, pf: { b, c, d, e, f in try pf(t, b, c, d, e, f) }) })
}

/// Given 7 explicit generators, converts a function to a universally quantified property using the
/// default shrinkers for those 7 types.
@warn_unused_result
public func forAll<A : Arbitrary, B : Arbitrary, C : Arbitrary, D : Arbitrary, E : Arbitrary, F : Arbitrary, G : Arbitrary>(genA : Gen<A>, _ genB : Gen<B>, _ genC : Gen<C>, _ genD : Gen<D>, _ genE : Gen<E>, _ genF : Gen<F>, _ genG : Gen<G>, pf : (A, B, C, D, E, F, G) throws -> Testable) -> Property {
	return forAll(genA, pf: { t in forAll(genB, genC, genD, genE, genF, genG, pf: { b, c, d, e, f, g in try pf(t, b, c, d, e, f, g) }) })
}

/// Given 8 explicit generators, converts a function to a universally quantified property using the
/// default shrinkers for those 8 types.
@warn_unused_result
public func forAll<A : Arbitrary, B : Arbitrary, C : Arbitrary, D : Arbitrary, E : Arbitrary, F : Arbitrary, G : Arbitrary, H : Arbitrary>(genA : Gen<A>, _ genB : Gen<B>, _ genC : Gen<C>, _ genD : Gen<D>, _ genE : Gen<E>, _ genF : Gen<F>, _ genG : Gen<G>, _ genH : Gen<H>, pf : (A, B, C, D, E, F, G, H) throws -> Testable) -> Property {
	return forAll(genA, pf: { t in forAll(genB, genC, genD, genE, genF, genG, genH, pf: { b, c, d, e, f, g, h in try pf(t, b, c, d, e, f, g, h) }) })
}

/// Given an explicit generator, converts a function to a universally quantified property for that
/// type.
///
/// This variant of `forAll` does not shrink its argument but allows generators of any type, not
/// just those that conform to `Arbitrary`.
@warn_unused_result
public func forAllNoShrink<A>(gen : Gen<A>, pf : (A throws -> Testable)) -> Property {
	return forAllShrink(gen, shrinker: { _ in [A]() }, f: pf)
}

/// Given 2 explicit generators, converts a function to a universally quantified property for those
/// 2 types.
///
/// This variant of `forAll` does not shrink its argument but allows generators of any type, not
/// just those that conform to `Arbitrary`.
@warn_unused_result
public func forAllNoShrink<A, B>(genA : Gen<A>, _ genB : Gen<B>, pf : (A, B) throws -> Testable) -> Property {
	return forAllNoShrink(genA, pf: { t in forAllNoShrink(genB, pf: { b in try pf(t, b) }) })
}

/// Given 3 explicit generators, converts a function to a universally quantified property for those
/// 3 types.
///
/// This variant of `forAll` does not shrink its argument but allows generators of any type, not
/// just those that conform to `Arbitrary`.
@warn_unused_result
public func forAllNoShrink<A, B, C>(genA : Gen<A>, _ genB : Gen<B>, _ genC : Gen<C>, pf : (A, B, C) throws -> Testable) -> Property {
	return forAllNoShrink(genA, pf: { t in forAllNoShrink(genB, genC, pf: { b, c in try pf(t, b, c) }) })
}

/// Given 4 explicit generators, converts a function to a universally quantified property
/// for those 4 types.
///
/// This variant of `forAll` does not shrink its argument but allows generators of any type, not
/// just those that conform to `Arbitrary`.
@warn_unused_result
public func forAllNoShrink<A, B, C, D>(genA : Gen<A>, _ genB : Gen<B>, _ genC : Gen<C>, _ genD : Gen<D>, pf : (A, B, C, D) throws -> Testable) -> Property {
	return forAllNoShrink(genA, pf: { t in forAllNoShrink(genB, genC, genD, pf: { b, c, d in try pf(t, b, c, d) }) })
}

/// Given 5 explicit generators, converts a function to a universally quantified property for those
/// 5 types.
///
/// This variant of `forAll` does not shrink its argument but allows generators of any type, not
/// just those that conform to `Arbitrary`.
@warn_unused_result
public func forAllNoShrink<A, B, C, D, E>(genA : Gen<A>, _ genB : Gen<B>, _ genC : Gen<C>, _ genD : Gen<D>, _ genE : Gen<E>, pf : (A, B, C, D, E) throws -> Testable) -> Property {
	return forAllNoShrink(genA, pf: { t in forAllNoShrink(genB, genC, genD, genE, pf: { b, c, d, e in try pf(t, b, c, d, e) }) })
}

/// Given 6 explicit generators, converts a function to a universally quantified property for those
/// 6 types.
///
/// This variant of `forAll` does not shrink its argument but allows generators of any type, not
/// just those that conform to `Arbitrary`.
@warn_unused_result
public func forAllNoShrink<A, B, C, D, E, F>(genA : Gen<A>, _ genB : Gen<B>, _ genC : Gen<C>, _ genD : Gen<D>, _ genE : Gen<E>, _ genF : Gen<F>, pf : (A, B, C, D, E, F) throws -> Testable) -> Property {
	return forAllNoShrink(genA, pf: { t in forAllNoShrink(genB, genC, genD, genE, genF, pf: { b, c, d, e, f in try pf(t, b, c, d, e, f) }) })
}

/// Given 7 explicit generators, converts a function to a universally quantified property for those
/// 7 types.
///
/// This variant of `forAll` does not shrink its argument but allows generators of any type, not
/// just those that conform to `Arbitrary`.
@warn_unused_result
public func forAllNoShrink<A, B, C, D, E, F, G>(genA : Gen<A>, _ genB : Gen<B>, _ genC : Gen<C>, _ genD : Gen<D>, _ genE : Gen<E>, _ genF : Gen<F>, _ genG : Gen<G>, pf : (A, B, C, D, E, F, G) throws -> Testable) -> Property {
	return forAllNoShrink(genA, pf: { t in forAllNoShrink(genB, genC, genD, genE, genF, genG, pf: { b, c, d, e, f, g in try pf(t, b, c, d, e, f, g) }) })
}

/// Given 8 explicit generators, converts a function to a universally quantified property for those
/// 8 types.
///
/// This variant of `forAll` does not shrink its argument but allows generators of any type, not
/// just those that conform to `Arbitrary`.
@warn_unused_result
public func forAllNoShrink<A, B, C, D, E, F, G, H>(genA : Gen<A>, _ genB : Gen<B>, _ genC : Gen<C>, _ genD : Gen<D>, _ genE : Gen<E>, _ genF : Gen<F>, _ genG : Gen<G>, _ genH : Gen<H>, pf : (A, B, C, D, E, F, G, H) throws -> Testable) -> Property {
	return forAllNoShrink(genA, pf: { t in forAllNoShrink(genB, genC, genD, genE, genF, genG, genH, pf: { b, c, d, e, f, g, h in try pf(t, b, c, d, e, f, g, h) }) })
}

/// Given an explicit generator and shrinker, converts a function to a universally quantified
/// property.
@warn_unused_result
public func forAllShrink<A>(gen : Gen<A>, shrinker : A -> [A], f : A throws -> Testable) -> Property {
	return Property(gen.bind { x in
		return shrinking(shrinker, initial: x, prop: { xs  in
			do {
				return (try f(xs)).counterexample(String(xs))
			} catch let e {
				return TestResult.failed("Test case threw an exception: \"" + String(e) + "\"")
			}
		}).unProperty
	})
}

/// Converts a function into an existentially quantified property using the default shrinker and
/// generator for that type to search for a passing case.  SwiftCheck only runs a limited number of
/// trials before giving up and failing.
///
/// The nature of Existential Quantification means SwiftCheck would have to enumerate over the 
/// entire domain of the type `A` in order to return a proper value.  Because such a traversal is 
/// both impractical and leads to computationally questionable behavior (infinite loops and the 
/// like), SwiftCheck instead interprets `exists` as a finite search over arbitrarily many values 
/// (around 500).  No shrinking is performed during the search.
///
/// Existential Quantification should rarely be used, and in practice is usually used for *negative*
/// statements "there does not exist `foo` such that `bar`". It is recommended that you avoid 
/// `exists` and instead reduce your property to 
/// [Skolem Normal Form](https://en.wikipedia.org/wiki/Skolem_normal_form).  `SNF` involves turning
/// every `exists` into a function returning the existential value, taking any other parameters 
/// being quantified over as needed.
public func exists<A : Arbitrary>(pf : A throws -> Testable) -> Property {
	return exists(A.arbitrary, pf: pf)
}

/// Given an explicit generator, converts a function to an existentially quantified property using
/// the default shrinker for that type.
public func exists<A : Arbitrary>(gen : Gen<A>, pf : A throws -> Testable) -> Property {
	return forAllNoShrink(A.arbitrary, pf: { try pf($0).invert }).invert.mapResult { res in
		return TestResult(ok:			res.ok
						, expect:		res.expect
						, reason:		res.reason
						, theException: res.theException
						, labels:		res.labels
						, stamp:		res.stamp
						, callbacks:	res.callbacks
						, abort:		res.abort
						, quantifier:	.Existential)
	}
}

/// Tests a property and prints the results to stdout.
public func quickCheck(prop : Testable, name : String = "") {
	quickCheckWithResult(stdArgs(name), p: prop)
}

/// MARK: - Implementation Details

internal func stdArgs(name : String = "") -> CheckerArguments {
	return CheckerArguments(replay: .None, maxAllowableSuccessfulTests: 100, maxAllowableDiscardedTests: 500, maxTestCaseSize: 100, name: name)
}

internal enum Result {
	case Success(numTests : Int
		, labels : [(String, Int)]
		, output : String
	)
	case GaveUp(numTests : Int
		, labels : [(String,Int)]
		, output : String
	)
	case Failure(numTests : Int
		, numShrinks : Int
		, usedSeed : StdGen
		, usedSize : Int
		, reason : String
		, labels : [(String,Int)]
		, output : String
	)
	case ExistentialFailure(numTests: Int
		, usedSeed : StdGen
		, usedSize : Int
		, reason : String
		, labels : [(String,Int)]
		, output : String
		, lastResult : TestResult
	)
	case  NoExpectedFailure(numTests : Int
		, labels : [(String,Int)]
		, output : String
	)
}

internal indirect enum Either<L, R> {
	case Left(L)
	case Right(R)
}

internal func quickCheckWithResult(args : CheckerArguments, p : Testable) -> Result {
	func roundTo(n : Int)(m : Int) -> Int {
		return (m / m) * m
	}

	func rnd() -> StdGen {
		switch args.replay {
		case Optional.None:
			return newStdGen()
		case Optional.Some(let (rnd, _)):
			return rnd
		}
	}

	func at0(f : Int -> Int -> Int)(s : Int)(n : Int)(d : Int) -> Int {
		if n == 0 && d == 0 {
			return s
		} else {
			return f(n)(d)
		}
	}

	let computeSize : Int -> Int -> Int = { x in
		let computeSize_ : Int -> Int -> Int  = { x in
			return { y in
				if	roundTo(x)(m: args.maxTestCaseSize) + args.maxTestCaseSize <= args.maxAllowableSuccessfulTests ||
					x >= args.maxAllowableSuccessfulTests ||
					args.maxAllowableSuccessfulTests % args.maxTestCaseSize == 0 {
						return min(x % args.maxTestCaseSize + (y / 10), args.maxTestCaseSize)
				} else {
					return min((x % args.maxTestCaseSize) * args.maxTestCaseSize / (args.maxAllowableSuccessfulTests % args.maxTestCaseSize) + y / 10, args.maxTestCaseSize)
				}
			}
		}

		return { y in
			if let (_, sz) = args.replay {
				return at0(computeSize_)(s: sz)(n: x)(d: y)
			}
			return computeSize_(x)(y)
		}
	}


	let istate = CheckerState(name: args.name
							, maxAllowableSuccessfulTests:		args.maxAllowableSuccessfulTests
							, maxAllowableDiscardedTests:	args.maxAllowableDiscardedTests
							, computeSize:			computeSize
							, successfulTestCount:		0
							, discardedTestCount:	0
							, labels:				[:]
							, collected:			[]
							, hasFulfilledExpectedFailure:		false
							, randomSeedGenerator:			rnd()
							, successfulShrinkCount:	0
							, failedShrinkStepDistance:		0
							, failedShrinkStepCount:		0
							, shouldAbort:			false
							, quantifier:			.Universal)
	let modP : Property = (p.exhaustive ? p.property.once : p.property)
	return test(istate, f: modP.unProperty.unGen)
}

// Main Testing Loop:
//
// Given an initial state and the inner function that runs the property begins turning a runloop
// that starts firing off individual test cases.  Only 3 functions get dispatched from this loop:
//
// - runATest: Does what it says; .Left indicates failure, .Right indicates continuation.
// - doneTesting: Invoked when testing the property fails or succeeds once and for all.
// - giveUp: When the number of discarded tests exceeds the number given in the arguments we just
//           give up turning the run loop to prevent excessive generation.
internal func test(st : CheckerState, f : (StdGen -> Int -> Prop)) -> Result {
	var state = st
	while true {
		switch runATest(state)(f: f) {
		case let .Left(fail):
			switch (fail.0, doneTesting(fail.1)(f: f)) {
			case (.Success(_, _, _), _):
				return fail.0
			case let (_, .NoExpectedFailure(numTests, labels, output)):
				return .NoExpectedFailure(numTests: numTests, labels: labels, output: output)
			// Existential Failures need explicit propagation.  Existentials increment the
			// discard count so we check if it has been surpassed.  If it has with any kind
			// of success we're done.  If no successes are found we've failed checking the
			// existential and report it as such.  Otherwise turn the testing loop.
			case (.ExistentialFailure(_, _, _, _, _, _, _), _):
				if fail.1.discardedTestCount >= fail.1.maxAllowableDiscardedTests && fail.1.successfulTestCount == 0 {
					return reportExistentialFailure(fail.1, res: fail.0)
				} else if fail.1.discardedTestCount >= fail.1.maxAllowableDiscardedTests {
					return doneTesting(fail.1)(f: f)
				} else {
					state = fail.1
					break
				}
			default:
				return fail.0
			}
		case let .Right(lsta):
			if lsta.successfulTestCount >= lsta.maxAllowableSuccessfulTests || lsta.shouldAbort {
				return doneTesting(lsta)(f: f)
			}
			if lsta.discardedTestCount >= lsta.maxAllowableDiscardedTests || lsta.shouldAbort {
				return giveUp(lsta)(f: f)
			}
			state = lsta
		}
	}
}

// Executes a single test of the property given an initial state and the generator function.
//
// On success the next state is returned.  On failure the final result and state are returned.
internal func runATest(st : CheckerState)(f : (StdGen -> Int -> Prop)) -> Either<(Result, CheckerState), CheckerState> {
	let size = st.computeSize(st.successfulTestCount)(st.discardedTestCount)
	let (rnd1, rnd2) = st.randomSeedGenerator.split

	// Execute the Rose Tree for the test and reduce to .MkRose.
	switch reduce(f(rnd1)(size).unProp) {
	case .MkRose(let resC, let ts):
		let res = resC() // Force the result only once.
		dispatchAfterTestCallbacks(st, res: res) // Then invoke the post-test callbacks

		switch res.match() {
			// Success
		case .MatchResult(.Some(true), let expect, _, _, let labels, let stamp, _, let abort, let quantifier):
			let nstate = CheckerState(name:							st.name
									, maxAllowableSuccessfulTests:	st.maxAllowableSuccessfulTests
									, maxAllowableDiscardedTests:	st.maxAllowableDiscardedTests
									, computeSize:					st.computeSize
									, successfulTestCount:			st.successfulTestCount.successor()
									, discardedTestCount:			st.discardedTestCount
									, labels:						unionWith(max, l: st.labels, r: labels)
									, collected:					[stamp] + st.collected
									, hasFulfilledExpectedFailure:	expect
									, randomSeedGenerator:			st.randomSeedGenerator
									, successfulShrinkCount:		st.successfulShrinkCount
									, failedShrinkStepDistance:		st.failedShrinkStepDistance
									, failedShrinkStepCount:		st.failedShrinkStepCount
									, shouldAbort:					abort
									, quantifier:					quantifier)
			return .Right(nstate)
			// Discard
		case .MatchResult(.None, let expect, _, _, let labels, _, _, let abort, let quantifier):
			let nstate = CheckerState(name:							st.name
									, maxAllowableSuccessfulTests:	st.maxAllowableSuccessfulTests
									, maxAllowableDiscardedTests:	st.maxAllowableDiscardedTests
									, computeSize:					st.computeSize
									, successfulTestCount:			st.successfulTestCount
									, discardedTestCount:			st.discardedTestCount.successor()
									, labels:						unionWith(max, l: st.labels, r: labels)
									, collected:					st.collected
									, hasFulfilledExpectedFailure:	expect
									, randomSeedGenerator:			rnd2
									, successfulShrinkCount:		st.successfulShrinkCount
									, failedShrinkStepDistance:		st.failedShrinkStepDistance
									, failedShrinkStepCount:		st.failedShrinkStepCount
									, shouldAbort:					abort
									, quantifier:					quantifier)
			return .Right(nstate)
			// Fail
		case .MatchResult(.Some(false), let expect, _, _, _, _, _, let abort, let quantifier):
			if quantifier == .Existential {
				print("")
			} else if !expect {
				print("+++ OK, failed as expected. ", terminator: "")
			} else {
				print("*** Failed! ", terminator: "")
			}

			// Failure of an existential is not necessarily failure of the whole test case,
			// so treat this like a discard.
			if quantifier == .Existential {
				let nstate = CheckerState(name:							st.name
										, maxAllowableSuccessfulTests:	st.maxAllowableSuccessfulTests
										, maxAllowableDiscardedTests:	st.maxAllowableDiscardedTests
										, computeSize:					st.computeSize
										, successfulTestCount:			st.successfulTestCount
										, discardedTestCount:			st.discardedTestCount.successor()
										, labels:						st.labels
										, collected:					st.collected
										, hasFulfilledExpectedFailure:	expect
										, randomSeedGenerator:			rnd2
										, successfulShrinkCount:		st.successfulShrinkCount
										, failedShrinkStepDistance:		st.failedShrinkStepDistance
										, failedShrinkStepCount:		st.failedShrinkStepCount
										, shouldAbort:					abort
										, quantifier:					quantifier)

				let resul = Result.ExistentialFailure(numTests: st.successfulTestCount + 1
													, usedSeed: st.randomSeedGenerator
													, usedSize: st.computeSize(st.successfulTestCount)(st.discardedTestCount)
													, reason: "Could not satisfy existential"
													, labels: summary(st)
													, output: "*** Failed! "
													, lastResult: res)
				return .Left((resul, nstate))
			}

			// Attempt a shrink.
			let (numShrinks, _, _) = findMinimalFailingTestCase(st, res: res, ts: ts())

			if !expect {
				let s = Result.Success(numTests: st.successfulTestCount.successor(), labels: summary(st), output: "+++ OK, failed as expected. ")
				return .Left((s, st))
			}

			let stat = Result.Failure(numTests:		st.successfulTestCount.successor()
									, numShrinks:	numShrinks
									, usedSeed:		st.randomSeedGenerator
									, usedSize:		st.computeSize(st.successfulTestCount)(st.discardedTestCount)
									, reason:		res.reason
									, labels:		summary(st)
									, output:		"*** Failed! ")

			let nstate = CheckerState(name:							st.name
									, maxAllowableSuccessfulTests:	st.maxAllowableSuccessfulTests
									, maxAllowableDiscardedTests:	st.maxAllowableDiscardedTests
									, computeSize:					st.computeSize
									, successfulTestCount:			st.successfulTestCount
									, discardedTestCount:			st.discardedTestCount.successor()
									, labels:						st.labels
									, collected:					st.collected
									, hasFulfilledExpectedFailure:	res.expect
									, randomSeedGenerator:			rnd2
									, successfulShrinkCount:		st.successfulShrinkCount
									, failedShrinkStepDistance:		st.failedShrinkStepDistance
									, failedShrinkStepCount:		st.failedShrinkStepCount
									, shouldAbort:					abort
									, quantifier:					quantifier)
			return .Left((stat, nstate))
		}
	default:
		fatalError("Pattern Match Failed: Rose should have been reduced to MkRose, not IORose.")
		break
	}
}

internal func doneTesting(st : CheckerState)(f : (StdGen -> Int -> Prop)) -> Result {
	if st.hasFulfilledExpectedFailure {
		print("*** Passed " + "\(st.successfulTestCount)" + pluralize(" test", i: st.successfulTestCount))
		printDistributionGraph(st)
		return .Success(numTests: st.successfulTestCount, labels: summary(st), output: "")
	} else {
		printDistributionGraph(st)
		return .NoExpectedFailure(numTests: st.successfulTestCount, labels: summary(st), output: "")
	}
}

internal func giveUp(st: CheckerState)(f : (StdGen -> Int -> Prop)) -> Result {
	printDistributionGraph(st)
	return Result.GaveUp(numTests: st.successfulTestCount, labels: summary(st), output: "")
}

// Interface to shrinking loop.  Returns (number of shrinks performed, number of failed shrinks,
// total number of shrinks performed).
//
// This ridiculously stateful looping nonsense is due to limitations of the Swift unroller and, more
// importantly, ARC.  This has been written with recursion in the past, and it was fabulous and
// beautiful, but it generated useless objects that ARC couldn't release on the order of Gigabytes
// for complex shrinks (much like `split` in the Swift STL), and was slow as hell.  This way we stay
// in one stack frame no matter what and give ARC a chance to cleanup after us.  Plus we get to
// stay within a reasonable ~50-100 megabytes for truly horrendous tests that used to eat 8 gigs.
internal func findMinimalFailingTestCase(st : CheckerState, res : TestResult, ts : [Rose<TestResult>]) -> (Int, Int, Int) {
	if let e = res.theException {
		fatalError("Test failed due to exception: \(e)")
	}

	var lastResult = res
	var branches = ts
	var successfulShrinkCount = st.successfulShrinkCount
	var failedShrinkStepDistance = st.failedShrinkStepDistance.successor()
	var failedShrinkStepCount = st.failedShrinkStepCount

	// cont is a sanity check so we don't fall into an infinite loop.  It is set to false at each
	// new iteration and true when we select a new set of branches to test.  If the branch
	// selection doesn't change then we have exhausted our possibilities and so must have reached a
	// minimal case.
	var cont = true
	while cont {
		/// If we're out of branches we're out of options.
		if branches.isEmpty {
			break;
		}

		cont = false
		failedShrinkStepDistance = 0

		// Try all possible courses of action in this Rose Tree
		branches.forEach { r in
			switch reduce(r) {
			case .MkRose(let resC, let ts1):
				let res1 = resC()
				dispatchAfterTestCallbacks(st, res: res1)

				// Did we fail?  Good!  Failure is healthy.
				// Try the next set of branches.
				if res1.ok == .Some(false) {
					lastResult = res1
					branches = ts1()
					cont = true
					break;
				}

				// Otherwise increment the tried shrink counter and the failed shrink counter.
				failedShrinkStepDistance++
				failedShrinkStepCount++
			default:
				fatalError("Rose should not have reduced to IO")
			}
		}

		successfulShrinkCount++
	}

	let state = CheckerState(name:							st.name
							, maxAllowableSuccessfulTests:	st.maxAllowableSuccessfulTests
							, maxAllowableDiscardedTests:	st.maxAllowableDiscardedTests
							, computeSize:					st.computeSize
							, successfulTestCount:			st.successfulTestCount
							, discardedTestCount:			st.discardedTestCount
							, labels:						st.labels
							, collected:					st.collected
							, hasFulfilledExpectedFailure:	st.hasFulfilledExpectedFailure
							, randomSeedGenerator:			st.randomSeedGenerator
							, successfulShrinkCount:		successfulShrinkCount
							, failedShrinkStepDistance:		failedShrinkStepDistance
							, failedShrinkStepCount:		failedShrinkStepCount
							, shouldAbort:					st.shouldAbort
							, quantifier:					st.quantifier)
	return reportMinimumCaseFound(state, res: lastResult)
}

internal func reportMinimumCaseFound(st : CheckerState, res : TestResult) -> (Int, Int, Int) {
	let testMsg = " (after \(st.successfulTestCount.successor()) test"
	let shrinkMsg = st.successfulShrinkCount > 1 ? (" and \(st.successfulShrinkCount) shrink") : ""

	print("Proposition: " + st.name)
	print(res.reason + pluralize(testMsg, i: st.successfulTestCount.successor()) + (st.successfulShrinkCount > 1 ? pluralize(shrinkMsg, i: st.successfulShrinkCount) : "") + "):")
	dispatchAfterFinalFailureCallbacks(st, res: res)
	return (st.successfulShrinkCount, st.failedShrinkStepCount - st.failedShrinkStepDistance, st.failedShrinkStepDistance)
}

internal func reportExistentialFailure(st : CheckerState, res : Result) -> Result {
	switch res {
	case let .ExistentialFailure(_, _, _, reason, _, _, lastTest):
		let testMsg = " (after \(st.discardedTestCount) test"

		print("*** Failed! ", terminator: "")
		print("Proposition: " + st.name)
		print(reason + pluralize(testMsg, i: st.discardedTestCount) + "):")
		dispatchAfterFinalFailureCallbacks(st, res: lastTest)
		return res
	default:
		fatalError("Cannot report existential failure on non-failure type \(res)")
	}
}

internal func dispatchAfterTestCallbacks(st : CheckerState, res : TestResult) {
	res.callbacks.forEach { c in
		switch c {
		case let .AfterTest(_, f):
			f(st, res)
		default:
			break
		}
	}
}

internal func dispatchAfterFinalFailureCallbacks(st : CheckerState, res : TestResult) {
	res.callbacks.forEach { c in
		switch c {
		case let .AfterFinalFailure(_, f):
			f(st, res)
		default:
			break
		}
	}
}

internal func summary(s : CheckerState) -> [(String, Int)] {
	let l = s.collected
		.flatMap({ l in l.map({ "," + $0 }).filter({ !$0.isEmpty }) })
		.sort()
		.groupBy(==)
	return l.map { ss in (ss.first!, ss.count * 100 / s.successfulTestCount) }
}

internal func labelPercentage(l : String, st : CheckerState) -> Int {
	let occur = st.collected.flatMap(Array.init).filter { $0 == l }
	return (100 * occur.count) / st.maxAllowableSuccessfulTests
}

internal func printLabels(st : TestResult) {
	if st.labels.isEmpty {
		print("(.)")
	} else if st.labels.count == 1, let pt = st.labels.first {
		print("(\(pt.0))")
	} else {
		let gAllLabels = st.labels.map({ (l, _) in
			return l + ", "
		}).reduce("", combine: +)
		print("("  + gAllLabels[gAllLabels.startIndex..<gAllLabels.endIndex.advancedBy(-2)] + ")")
	}
}

internal func printDistributionGraph(st : CheckerState) {
	func showP(n : Int) -> String {
		return (n < 10 ? " " : "") + "\(n)" + "%"
	}

	let gAllLabels = st.collected.map({ (s : Set<String>) in
		return Array(s).filter({ t in st.labels[t] == .Some(0) }).reduce("", combine: { (l : String, r : String) in l + ", " + r })
	})
	let gAll = gAllLabels.filter({ !$0.isEmpty }).sort().groupBy(==)
	let gPrint = gAll.map({ ss in showP((ss.count * 100) / st.successfulTestCount) + ss.first! })
	let allLabels = Array(gPrint.sort().reverse())

	var covers = [String]()
	st.labels.forEach { (l, reqP) in
		let p = labelPercentage(l, st: st)
		if p < reqP {
			covers += ["only \(p)% " + l + ", not \(reqP)%"]
		}
	}

	let all = covers + allLabels
	if all.isEmpty {
		print(".")
	} else if all.count == 1, let pt = all.first {
		print("(\(pt))")
	} else {
		print(":")
		all.forEach { pt in
			print(pt)
		}
	}
}

internal func cons<T>(lhs : T, var _ rhs : [T]) -> [T] {
	rhs.insert(lhs, atIndex: 0)
	return rhs
}

private func pluralize(s : String, i : Int) -> String {
	if i == 1 {
		return s
	}
	return s + "s"
}

extension Array {
	internal func groupBy(p : (Element , Element) -> Bool) -> [[Element]] {
		func span(list : [Element], p : (Element -> Bool)) -> ([Element], [Element]) {
			if list.isEmpty {
				return ([], [])
			} else if let x = list.first {
				if p (x) {
					let (ys, zs) = span([Element](list[1..<list.endIndex]), p: p)
					return (cons(x, ys), zs)
				}
				return ([], list)
			}
			fatalError("span reached a non-empty list that could not produce a first element")
		}

		if self.isEmpty {
			return []
		} else if let x = self.first {
			let (ys, zs) = span([Element](self[1..<self.endIndex]), p: { p(x, $0) })
			let l = cons(x, ys)
			return cons(l, zs.groupBy(p))
		}
		fatalError("groupBy reached a non-empty list that could not produce a first element")
	}
}
