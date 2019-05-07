package de.fzi.emfcompare.matching.suite

import de.fzi.emfcompare.matching.matches.Element
import de.fzi.emfcompare.matching.matches.ElementID
import de.fzi.emfcompare.matching.matches.ElementPath
import de.fzi.emfcompare.matching.matches.ElementPosition
import de.fzi.emfcompare.matching.matches.ElementURI
import de.fzi.emfcompare.matching.matches.Except
import de.fzi.emfcompare.matching.matches.MatchElement
import de.fzi.emfcompare.matching.matches.MatchTree
import de.fzi.emfcompare.matching.matches.MatchesFactory
import de.fzi.emfcompare.matching.matches.MatchesPackage
import de.fzi.emfcompare.matching.matches.Model
import de.fzi.emfcompare.matching.matches.NoElement
import de.fzi.emfcompare.matching.util.EnclosedModelInstance
import java.util.ArrayList
import java.util.List
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.compare.Match
import org.eclipse.emf.compare.match.impl.MatchEngineFactoryImpl
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl
import org.eclipse.emf.ecore.util.EcoreUtil

import static de.fzi.emfcompare.matching.util.EmfTagExtensions.*

import static extension de.fzi.emfcompare.matching.util.EmfCompareExtensions.getUri
import static extension de.fzi.emfcompare.matching.util.EmfTagExtensions.isTagged

/**
 * Implements the AbstractMatchingTestCase for match expectations described in the Matches DSL (.matches files)
 */
class DSLMatchingTestCase extends AbstractMatchingTestCase {

	EnclosedModelInstance left
	EnclosedModelInstance right
	Model model
	

	override getMatchEngine() { new MatchEngineFactoryImpl().matchEngine }

	override init(URI _before, URI _after, URI expectedMatches, String suiteName) {
		if (expectedMatches === null)
			fail("No Resources found")
		resourceBefore = new ResourceSetImpl()
		resourceAfter = new ResourceSetImpl()
		resourceMatches = new ResourceSetImpl()
		testSuiteName = suiteName

		resourceMatches.getResource(expectedMatches, true)

		var resource = resourceMatches.resources.get(0)
		if (resource === null || !(resource.contents.get(0) instanceof Model))
			fail('''Provided matches resource is not of type «MatchesPackage.eNS_URI»!''');
		model = resource.contents.get(0) as Model

		if (model === null || !model.loadResources(_before, _after))
			fail('''Resources for file «expectedMatches.toFileString» could not be loaded!''');

		name = "runTest: " + expectedMatches.toFileString;
	}

	override void interpretComparisonResult(List<Match> matches) {
		// Create queue
		val queue = model.matches.toList

		for (var i = 0; i < queue.length; i++) {
			var match = queue.get(i)
			switch match {
				MatchTree: {
					val leftEObject = left.resolveElement(match.match.left)
					val rightEObject = right.resolveElement(match.match.right)
					var leftCandidates = if(leftEObject !== null) new ArrayList(leftEObject.eContents) else #[]
					var rightCandidates = if(rightEObject !== null) new ArrayList(rightEObject.eContents) else #[]

					// Remove already matched and tagged elements
					leftCandidates = leftCandidates.filter[!isTagged].toList
					rightCandidates = rightCandidates.filter[!isTagged].toList

					// Add single match for tree root to the queue
					queue.add(createMatchElement(
						createElementURI(leftEObject.uri),
						createElementURI(rightEObject.uri)
					));
					tag(leftEObject, rightEObject)

					// Create Matches for except-candidates	
					if (match.except !== null) {
						for (except : match.except.except) {
							val exceptLeft = left.resolveElement(except.left, leftEObject)
							val exceptRight = right.resolveElement(except.right, rightEObject)
							if (exceptLeft !== null)
								leftCandidates.removeIf[exceptLeft.uri == it.uri]
							if (exceptRight !== null)
								rightCandidates.removeIf[exceptRight.uri == it.uri]
							queue.add(createMatchTree(
								createElementURI(exceptLeft.uri),
								createElementURI(exceptRight.uri),
								except.except
							))
							tag(exceptLeft, exceptRight)
						}
					}
					// Create 1<->1 tree matches for the rest of the candidates
					for (var j = 0; j < leftCandidates.length || j < rightCandidates.length; j++) {
						var leftCandidate = if(j < leftCandidates.length) leftCandidates.get(j) else null
						var rightCandidate = if(j < rightCandidates.length) rightCandidates.get(j) else null
						// Generate Path/URI for elements and create Tree Matches if one contains elements
						var pathLeft = if(leftCandidate === null) createNoElement else createElementURI(
								EcoreUtil.getURI(leftCandidate))
						var pathRight = if(rightCandidate === null) createNoElement else createElementURI(
								EcoreUtil.getURI(rightCandidate))
						if ((leftCandidate === null || leftCandidate.eContents.empty) &&
							(rightCandidate === null || rightCandidate.eContents.empty)) {
							queue.add(createMatchElement(pathLeft, pathRight))
						} else {
							queue.add(createMatchTree(pathLeft, pathRight, null))
						}
						tag(leftCandidate, rightCandidate)
					}

				}
				MatchElement: {
					var leftElem = left.resolveElement(match.left)
					var rightElem = right.resolveElement(match.right)
					if (!matches.removeMatch(
						leftElem,
						rightElem
					))
						fail('''Match (left=«leftElem» | right=«rightElem») was not created by EmfCompare!''')
					else {
						tag(leftElem, rightElem)
					}
				}
				default:
					fail("Invalid matches resource")
			}
		}
		logger.info('''Remaining matches by EmfCompare: «matches»''')
		assertTrue("EmfCompare found more matches than expected!", matches.isEmpty)
	}

	private def resolveElement(EnclosedModelInstance model, Element element, EObject from) {
		switch element {
			ElementID:
				model.find(element.uuid)
			ElementPosition:
				from.eContents.get(element.position)
			ElementURI:
				model.find(URI.createURI(element.uri))
			ElementPath: {
				if (element.path !== null && element.path.startsWith("/"))
					model.resolveElement(element.path)
				else
					model.resolveElement(from, element.path)
			}
			NoElement:
				null
			default:
				fail("Invalid matches resource")
		}
	}

	private def resolveElement(EnclosedModelInstance model, Element element) {
		resolveElement(model, element, model.root)
	}

	private def boolean removeMatch(List<Match> matches, EObject left, EObject right) {
		matches.removeIf [
			it.left.uri == left.uri && it.right.uri == right.uri && {
				logger.debug("Matched and removed " + it);
				true
			}
		]
	}

	private def boolean loadResources(Model model, URI before, URI after) {
		if (model.left.nullOrEmpty && before === null || model.right.nullOrEmpty && after === null)
			return false
		val uriLeft = if(!model.left.nullOrEmpty) model.left.uri else before
		val uriRight = if(!model.right.nullOrEmpty) model.right.uri else after
		left = new EnclosedModelInstance(uriLeft)
		right = new EnclosedModelInstance(uriRight)
		resourceBefore.getResource(uriLeft, true)
		resourceAfter.getResource(uriRight, true)
		true
	}

	private def NoElement createNoElement() {
		MatchesFactory.eINSTANCE.createNoElement
	}

	private def Element createElementURI(String uri) {
		if(uri === null || uri == "") return createNoElement
		var newElement = MatchesFactory.eINSTANCE.createElementURI
		newElement.uri = uri
		newElement
	}

	private def Element createElementURI(URI uri) {
		if(uri === null) return createNoElement else createElementURI(uri.toString)
	}

	private def MatchElement createMatchElement(Element left, Element right) {
		var newMatch = MatchesFactory.eINSTANCE.createMatchElement
		newMatch.left = left.clone
		newMatch.right = right.clone
		newMatch
	}

	private def MatchTree createMatchTree(Element left, Element right, Except except) {
		var newTree = MatchesFactory.eINSTANCE.createMatchTree
		newTree.match = createMatchElement(left, right)
		newTree.except = except.clone
		newTree
	}

	private def <T extends EObject> T clone(T e) {
		EcoreUtil.copy(e)
	}
}
