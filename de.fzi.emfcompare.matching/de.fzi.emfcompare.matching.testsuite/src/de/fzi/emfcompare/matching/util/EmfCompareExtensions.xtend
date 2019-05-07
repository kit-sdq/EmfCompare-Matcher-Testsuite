package de.fzi.emfcompare.matching.util

import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.util.EcoreUtil
import org.eclipse.emf.common.util.URI
import java.io.File

/**
 * The <b>EmfCompareExtensions</b> class provides extension methods to construct EMF URI's from EObjects, Files or Strings.
 */
class EmfCompareExtensions {
	
	/** Returns the URI of the given {@link EObject}, calculated with the {@link EcoreUtil}*/
	static def getUri(EObject object) {
		if(object === null) return null
		EcoreUtil.getURI(object)
	}
	
	/** Returns the FileURI of the given {@link File}, calculated with the {@link EcoreUtil}*/
	static def getUri(File file) {
		if(file === null) return null
		URI.createFileURI(file.absolutePath)
	}
	
	/** Returns the FileURI of the given {@link String}, calculated with the {@link EcoreUtil}*/
	static def getUri(String destination) {
		if(destination.isNullOrEmpty) return null
		URI.createFileURI(destination)
	}
}