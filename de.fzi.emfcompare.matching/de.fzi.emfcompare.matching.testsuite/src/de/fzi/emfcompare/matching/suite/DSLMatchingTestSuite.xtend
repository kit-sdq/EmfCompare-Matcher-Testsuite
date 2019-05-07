package de.fzi.emfcompare.matching.suite

import de.fzi.emfcompare.matching.suite.AbstractMatchingTestSuite
import java.util.List
import java.io.File
import java.io.FileNotFoundException
import static extension de.fzi.emfcompare.matching.util.EmfCompareExtensions.getUri
import org.eclipse.emf.common.util.URI

/**
 * Implements the AbstractMatchingTestSuite for match expectations described in the Matches DSL (.matches files) using the DSLMatchingTestCase
 * 
 * @author Fabian Scheytt
 */
class DSLMatchingTestSuite extends AbstractMatchingTestSuite{
	
	override protected getTestName() { "DSLMatchingTestSuite" }
	
	override protected getTestCase() { new DSLMatchingTestCase }
	
	override protected getDiffFileExtension() { "matches" }

	override protected List<Object[]> getFiles() {
		// Instances to compare should be specified in the matches model
		val folderBefore = new File(beforeLocation)
		val folderAfter = new File(afterLocation)
		val folderMatches = new File(matchesLocation)
		
		val validBeforeAfterFolders = folderBefore.exists() && folderAfter.exists && folderBefore.directory && folderAfter.directory
		
		if (!folderMatches.exists)
   			throw new FileNotFoundException("Given |matches| location parameter cannot be found!")
		if (!folderMatches.directory)
			throw new IllegalArgumentException("Given  |matches| location parameter has to be a directory!")
		
		// Matches resource should contains other resource paths (left|right)
		// add same resource file names as contingency plan if no paths are defined in the Matches resource
		folderMatches.listFiles([dir, name| return name.toLowerCase().endsWith("." + diffFileExtension)]).map[file |
			var URI before = null
			var URI after = null
			if(validBeforeAfterFolders && file.name.contains(".") &&
				folderAfter.listFiles.exists[it.name == file.name.substring(0, file.name.lastIndexOf('.')+1) + modelFileExtension] &&
				folderBefore.listFiles.exists[it.name == file.name.substring(0, file.name.lastIndexOf('.')+1) + modelFileExtension])
			{
				before = folderBefore.listFiles.findFirst[it.name == file.name.substring(0, file.name.lastIndexOf('.')+1) + modelFileExtension].uri
				after = folderAfter.listFiles.findFirst[it.name == file.name.substring(0, file.name.lastIndexOf('.')+1) + modelFileExtension].uri
			}
			#[before, after, file.uri].toArray
		].toList
	}
}
