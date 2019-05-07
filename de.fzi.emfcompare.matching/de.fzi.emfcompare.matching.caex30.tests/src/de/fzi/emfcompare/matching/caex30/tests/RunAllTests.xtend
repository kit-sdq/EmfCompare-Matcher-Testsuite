package de.fzi.emfcompare.matching.caex30.tests

import caex.caex30.caex.CAEXPackage
import de.fzi.emfcompare.matching.MatchesStandaloneSetup
import de.fzi.emfcompare.matching.suite.MatchingTestsFactory
import edu.kit.ipd.sdq.metamodels.recipients.RecipientsPackage
import junit.framework.Test
import org.apache.log4j.PropertyConfigurator
import org.eclipse.emf.compare.ComparePackage

/**
 * Runs all EMFCompare Matcher tests
 */
class RunAllTests {
	
	/**
	 * The <b>static</b> suite method is picked up by JUnit and executed as a TestSuite
	 */
	def static Test suite() {
		registerPackages
		configureLogging
		var factory = new MatchingTestsFactory()
		
		var suiteBuilder = factory.createMatchingTestBuilder("de.fzi.emfcompare.matching.caex30.tests")
		
		suiteBuilder.addMatcherTest(
			factory.createDSLMatchingTestSuite("CAEXMatchingTestSuite", "caex"),
			factory.createDefaultMatchingTestSuite("DefaultMatchingTestSuite","caex")
		).buildSuite
	}
	
	/**
	 * Registering required EMF Packages is necessary for headless execution, e.g. for a maven build
	 */
	def static registerPackages() {
		MatchesStandaloneSetup.doSetup()
		val initCaex = CAEXPackage.eINSTANCE
		val initCompare = ComparePackage.eINSTANCE
		val initRecips = RecipientsPackage.eINSTANCE
	}
	
	/**
	 * Configures Log4j
	 */
	def static configureLogging() {
		PropertyConfigurator.configure("log4j.properties");
	}
}