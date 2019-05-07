package de.fzi.emfcompare.matching.suite

import org.eclipse.emf.compare.match.IMatchEngine

/**
 * Factory for the matches test suite
 */
class MatchingTestsFactory {

	/**
	 * Creates a AbstractMatchingTestBuilder implementation with the given name
	 */
	def AbstractMatchingTestBuilder createMatchingTestBuilder(String name) {
		return new AbstractMatchingTestBuilder() {
			override testSuiteName() { name }
		}
	}

	/**
	 * Creates a custom DSLMatchingTestSuite implementation that uses the given parameters
	 */
	def DSLMatchingTestSuite createDSLMatchingTestSuite(String suiteName, String modelExtension) {
		return new DSLMatchingTestSuite() {
			override getTestName() { suiteName }
			override getModelFileExtension() { modelExtension }
		}
	}

	/**
	 * Creates a custom DSLMatchingTestSuite implementation that uses the given parameters
	 */
	def DSLMatchingTestSuite createDSLMatchingTestSuite(String suiteName, String modelExtension, IMatchEngine e) {
		return new DSLMatchingTestSuite() {
			override getTestName() { suiteName }
			override getModelFileExtension() { modelExtension }
			override getTestCase() { createDSLMatchingTestCase(e) }
		}
	}

	/**
	 * Creates a custom DefaultMatchingTestSuite implementation that uses the given parameters
	 */
	def DefaultMatchingTestSuite createDefaultMatchingTestSuite(String suiteName, String modelExtension) {
		return new DefaultMatchingTestSuite() {
			override getTestName() { suiteName }
			override getModelFileExtension() { modelExtension }
		}
	}

	/**
	 * Creates a custom DefaultMatchingTestSuite implementation that uses the given parameters
	 */
	def DefaultMatchingTestSuite createDefaultMatchingTestSuite(String suiteName, String modelExtension,
		IMatchEngine e) {
		return new DefaultMatchingTestSuite() {
			override getTestName() { suiteName }
			override getModelFileExtension() { modelExtension }
			override getTestCase() { createDefaultMatchingTestCase(e) }
		}
	}

	/**
	 * Creates a custom DSLMatchingTestCase implementation that uses the given IMatchEngine implementation
	 */
	def DSLMatchingTestCase createDSLMatchingTestCase(IMatchEngine engine) {
		return new DSLMatchingTestCase() {
			override getMatchEngine() {	engine }
		}
	}

	/**
	 * Creates a custom DefaultMatchingTestCase implementation that uses the given IMatchEngine implementation
	 */
	def DefaultMatchingTestCase createDefaultMatchingTestCase(IMatchEngine engine) {
		return new DefaultMatchingTestCase() {
			override getMatchEngine() { engine }
		}
	}

}
