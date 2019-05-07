package de.fzi.emfcompare.matching.suite

import java.io.File
import java.io.FileNotFoundException
import java.util.List
import junit.framework.TestSuite
import org.eclipse.emf.common.util.URI

import static extension de.fzi.emfcompare.matching.util.EmfCompareExtensions.getUri
/**
 * <p>The AbstractMatchingTestSuite provides the base implementation for a MatchingTestSuite.</p>
 * <p>
 * The folders at {@link #beforeLocation} and {@link #afterLocation} should contain the before and after
 * models that are to be compared with the extension specified at {@link #getModelFileExtension}. <br/>
 * The folder at {@link #matchesLocation} should contain a file with the extension {@link #getDiffFileExtension}
 * that specifies the matches that are expected by comparing the two given models with EMFCompare.
 * </p>
 * <p>
 * When executed the {@link AbstractMatchingTestCase} specified at {@link #getTestCase} is carried out
 * for each triplet of files with the same name in the respective {@link #beforeLocation},{@link #matchesLocation},{@link #afterLocation} folders.
 * </p>
 * 
 */
abstract class AbstractMatchingTestSuite extends TestSuite {
	protected String beforeLocation = "before"
	protected String afterLocation = "after"
	protected String matchesLocation = "expectedMatches"
	
	protected def getModelFileExtension() { "caex" }
	protected def getDiffFileExtension() { "compare" }
	
	def abstract protected String getTestName();
	def abstract protected AbstractMatchingTestCase getTestCase();
	
	new() {
		super("AbstractMatchingTestSuite")
		super.name = getTestName;		
		
		for (file : files){
			var test = testCase
			if(test !== null) {
				test.init(file.get(0) as URI, file.get(1) as URI, file.get(2) as URI, super.name)
				addTest(test)				
			}	
		}
	}
	
	protected def List<Object[]> getFiles() {
		val folderBefore = new File(beforeLocation)
		val folderAfter = new File(afterLocation)
		val folderMatches = new File(matchesLocation)
		
		if (!folderBefore.exists() || !folderAfter.exists || !folderMatches.exists)
   			throw new FileNotFoundException("Given (before|after|matches) location parameters cannot be found!")
		if (!folderBefore.directory || !folderAfter.directory || !folderMatches.directory)
			throw new IllegalArgumentException("Given (before|after|matches) location parameters have to be directories!")
		
		folderBefore.listFiles([dir, name | return name.toLowerCase().endsWith("." + modelFileExtension)]).filter[ file | 
			folderAfter.listFiles.exists[it.name == file.name] && 
			folderMatches.listFiles.exists[it.name == file.name.substring(0, file.name.lastIndexOf('.')+1) + diffFileExtension]
		].map[file |
			#[file.uri,
			folderAfter.listFiles.findFirst[it.name == file.name].uri,
			folderMatches.listFiles.findFirst[it.name == file.name.substring(0, file.name.lastIndexOf('.')+1) + diffFileExtension].uri ].toArray
		].toList
	}
}