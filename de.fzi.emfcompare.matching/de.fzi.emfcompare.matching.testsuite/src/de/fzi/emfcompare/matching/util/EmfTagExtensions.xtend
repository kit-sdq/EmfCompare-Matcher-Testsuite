package de.fzi.emfcompare.matching.util

import org.eclipse.emf.ecore.EObject
import org.slf4j.Logger
import org.slf4j.LoggerFactory

/**
 * The <b>EmfTagExtensions</b> class provides extension methods to tag/untag emf {@link EObject}s
 * by attaching or removing the {@link AlreadyMatchedAdapter}.
 */
class EmfTagExtensions {
	static Logger logger = LoggerFactory.getLogger(EmfTagExtensions)
	
	/**
	 * Tags the given {@link EObject} by attaching an {@link AlreadyMatchedAdapter} if {@link EmfTagExtensions#isTagged} evaluates to false
	 */
	static def boolean tag(EObject object) {
		if(object === null || isTagged(object)) return true
		val res = object.eAdapters.add(new AlreadyMatchedAdapter)
		if (!res) logger.debug('''Tagging of object «object» failed!''')
		res
	}
	
	/**
	 * Tags all given objects by executing the {@link EmfTagExtensions#tag} method
	 * @returns true if all objects were successfully tagged
	 */
	static def boolean tag(EObject ... objects) {
		val result = new MutableBoolean(true)
		objects.forEach[result.value = it.tag && result.value]
		result.value
	}
	
	/**
	 * Untags the given object if it has been tagged
	 * @returns true if the object was successfully untagged
	 */
	static def boolean unTag(EObject object) {
		if(object === null) return false
		val res = object.eAdapters.removeIf[it instanceof AlreadyMatchedAdapter]
		if (!res) logger.debug('''Un-Tagging of object «object» failed!''')
		res
	}
	
	/**
	 * Untags all given objects if they have been tagged
	 * @returns true if all objects were successfully untagged
	 */
	static def boolean unTag(EObject ... objects) {
		val result = new MutableBoolean(true)
		objects.forEach[result.value = it.unTag && result.value]
		result.value
	}
	
	/**
	 * Evaluates to true if the given {@link EObject} has been tagged with an {@link AlreadyMatchedAdapter}, false otherwise
	 * @return true if object has been tagged
	 */
	static def boolean isTagged(EObject object) {
		if(object === null) return true
		!object.eAdapters.filter[it instanceof AlreadyMatchedAdapter].empty
	}
	
	private static class MutableBoolean {		
		new(boolean value) {
			this.value = value
		}
		
		public boolean value
	}
}