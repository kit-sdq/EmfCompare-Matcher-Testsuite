package de.fzi.emfcompare.matching.suite

/**
 * <p>Default implementation of the {@link AbstractMatchingTestSuite} class.</p>
 * <p>For this implementation the expected matches have to be defined as an EMFCompare .compare Model, for
 * a more comfortable way of specifying the expected matches, see {@link DSLMatchingTestSuite} and
 * {@link DSLDefaultMatchingTestCase} as well as the Matches domain specific language {@link de.fzi.emfcompare.matching.matches}.</p>
 * 
 * <p>The Models that should be compared are in the /before and /after folders of the executing plugin and are instances of the CAEX metamodel.<br/>
 * The expected Matches are specified by EMFCompare instances (.compare files) and are stored in the /expectedMatches folder of the executing plugin.</p>
 * 
 * <p>The test case to be executed for each triplet of before, after model and expected matches specification is the {@DefaultMatchingTestCase}.</p>
 * 
 */
class DefaultMatchingTestSuite extends AbstractMatchingTestSuite{
	
	override protected getTestName() { "Matching Test Suite" }
	
	override protected getTestCase() { new DefaultMatchingTestCase }
	
}