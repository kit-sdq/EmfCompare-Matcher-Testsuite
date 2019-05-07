package de.fzi.emfcompare.matching.suite

import org.eclipse.emf.compare.match.impl.MatchEngineFactoryImpl
import static extension de.fzi.emfcompare.matching.util.EmfCompareExtensions.getUri
import java.util.List
import org.eclipse.emf.compare.Match
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl

/**
 * Default implementation of the {@link AbstractMatchingTestCase} class.
 * Simply compares the list of matches found by EMFCompare with the expectedMatches.
 * For this implementation the expected matches have to be defined as an EMFCompare .compare Model, for
 * a more comfortable way of specifying the expected matches, see {@link DSLMatchingTestSuite} and
 * {@link DSLDefaultMatchingTestCase} as well as the Matches domain specific language {@link de.fzi.emfcompare.matching.matches}.
 */
class DefaultMatchingTestCase extends AbstractMatchingTestCase{
	
	override getMatchEngine() {
		new MatchEngineFactoryImpl().matchEngine
	}
	
	override init(URI before, URI after, URI expectedMatches, String suiteName){
		if(before === null || after === null || expectedMatches === null) 
			fail("No Resources found")
		
		resourceBefore = new ResourceSetImpl()
		resourceAfter = new ResourceSetImpl()
		resourceMatches = new ResourceSetImpl()
		testSuiteName = suiteName
		
		resourceBefore.getResource(before, true)
		resourceAfter.getResource(after, true)
		resourceMatches.getResource(expectedMatches, true)
		
		name = "runTest:" + before.toFileString;	
	}
	
	override protected void interpretComparisonResult(List<Match> matches) {
		var predictedMatches = resourceMatches.allContents.toList
			.filter[it instanceof Match].toList.map[it as Match]
		
		for(match : predictedMatches.toList)
		{
			var resolve = matches.findFirst[
				it.left.uri == match.left.uri &&
				it.right.uri == match.right.uri]
				
			if (resolve === null)
				fail('''Not all Matches resolved! Sibling for Match <left: «match.left.uri», right: «match.right.uri» can't be resolved.''')
			else
				assertTrue(matches.remove(resolve))
		}		
		//Assert that all expected matches were found
		assertTrue(matches.empty)
	}
}