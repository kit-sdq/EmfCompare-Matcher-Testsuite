package de.fzi.emfcompare.matching.suite

import junit.framework.TestSuite
import junit.framework.Test
import java.util.List
import java.util.ArrayList

/**
 * Represents a test suite builder that combines different implementations of the 
 * {@link AbstractMatchingTestSuite} to one executable Test.
 * 
 * @author Fabian Scheytt
 */
abstract class AbstractMatchingTestBuilder {
	
	abstract def String testSuiteName()

	List<Class<? extends AbstractMatchingTestSuite>> tests = new ArrayList<Class<? extends AbstractMatchingTestSuite>>()
	List<AbstractMatchingTestSuite> instanceTests = new ArrayList<AbstractMatchingTestSuite>()
	
	/**
	 * Creates and returns an {@link junit.framework.Test} that contains all added {@link AbstractMatchingTestSuite} for execution.
	 */
	def Test buildSuite() {    	
        val suite = new TestSuite(testSuiteName)
        for(test : tests){
        	// Inner Classes can't be instantiated
        	if(test.enclosingClass === null) {
	        	var run = test.getDeclaredConstructor.newInstance
	        	suite.addTest(run)        	
        	}
        }
        for(test : instanceTests){
        	if(test !== null)
        		suite.addTest(test)        	
        }        
        return suite
	}
	
	/**
	 * Adds an {@link AbstractMatchingTestSuite} implementation to the test suite.
	 */
	def AbstractMatchingTestBuilder addMatcherTest(Class<? extends AbstractMatchingTestSuite> ... matcherTests) {
		tests.addAll(matcherTests)
		this
	}
	
	/**
	 * Adds an instantiated {@link AbstractMatchingTestSuite} to the test suite. Useful for adding anonymous classes to the suite.
	 */
	def AbstractMatchingTestBuilder addMatcherTest(AbstractMatchingTestSuite ... matcherTests) {
		instanceTests.addAll(matcherTests)
		this
	}
}