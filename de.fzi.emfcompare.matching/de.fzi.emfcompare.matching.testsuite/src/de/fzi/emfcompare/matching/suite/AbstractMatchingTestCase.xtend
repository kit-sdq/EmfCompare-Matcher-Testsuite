package de.fzi.emfcompare.matching.suite

import java.util.List
import junit.framework.TestCase
import org.eclipse.emf.common.util.BasicMonitor
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.compare.Match
import org.eclipse.emf.compare.match.IMatchEngine
import org.eclipse.emf.compare.scope.DefaultComparisonScope
import org.eclipse.emf.ecore.resource.ResourceSet
import org.slf4j.Logger
import org.slf4j.LoggerFactory

/**
 * Abstract implementation for a MatchingTestCase. See {@link DefaultMatchingTestCase} for a default
 * implementation for comparing any models and specifying expected matches with a EMFCompare model 
 */
abstract class AbstractMatchingTestCase extends TestCase{
	
	protected static Logger logger = LoggerFactory.getLogger(AbstractMatchingTestCase)
	
	protected ResourceSet resourceBefore
	protected ResourceSet resourceAfter
	protected ResourceSet resourceMatches
	protected String testSuiteName = ""
	
	/**
	 * Initializes the test case by at least loading the resources and potentially setting the test name 
	 */
	abstract def void init(URI before, URI after, URI expectedMatches, String testSuiteName)
	
	/**
	 * Returns the EMFCompare {@link IMatchEngine} that is used to compare the models 
	 */
	abstract def IMatchEngine getMatchEngine()
	
	/**
	 * Runs the test case by first matching the two models with EMFCompare and the calling the 
	 * {@link #interpretComparisonResult} method with the resulting matches.
	 */
	override void runTest() throws Throwable {
		logger.debug('''Now running «testSuiteName» Test for: «resourceMatches.resources?.get(0)?.URI?.toFileString»''')
	    var allMatches = matchModels
		interpretComparisonResult(allMatches)
	}	
	
	/**
	 * Matches the models at {@link #resourceBefore} and {@link #resourceAfter} 
	 * with the EMFCompare IMatchEngine specified at {@link #getMatchEngine()}
	 */
	def List<Match> matchModels() {
		//compare resources before and after
		val	scope = new DefaultComparisonScope(resourceBefore, resourceAfter, null)
		val	comparison = matchEngine.match(scope,new BasicMonitor)
		//Extract all matches as a list from the comparison result
		comparison.eAllContents.toList
			.filter[it instanceof Match].toList.map[it as Match]
	}
	
	/**
	 * Interprets the EMFCompare results with JUnit assertions.
	 */
	abstract protected def void interpretComparisonResult(List<Match> matches)
}