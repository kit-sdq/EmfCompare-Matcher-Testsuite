package de.fzi.emfcompare.matching.util

import java.util.HashMap
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.common.util.TreeIterator

/**
 * The SimpleUuidResolver is able to register/unregister EObjects by their
 * identifiers (ID) and at a later point resolve the registered EObject by it's ID. 
 */
class SimpleUuidResolver {
	HashMap<String, EObject> uuidStore = new HashMap

	/**
	 * Finds the EObject that is identified by the given id, <b>if</b> the objects has previously been registered.
	 */
	def find(String uuid) {
		uuidStore.get(uuid)
	}

	/**
	 * Registers the given EObject if any feature represents an ID.
	 */
	def register(EObject obj) {
		for (feature : obj.eClass.EAllAttributes) {
			if (feature.isID)
				register(obj.eGet(feature) as String, obj)
		}
	}

	/**
	 * Registers each EObjects if any feature of the EObject represents an ID.
	 */
	def register(TreeIterator<EObject> iterable) {
		while (iterable.hasNext) {
			var elem = iterable.next
			elem.register
		}
	}

	/**
	 * Registers the given String as ID of the EObject.
	 */
	def register(String id, EObject obj) {
		uuidStore.put(id, obj)
	}

	/**
	 * Removes the EObject that is represented by the given ID from the registry if it has previously been registered.
	 */
	def unregister(String id) {
		uuidStore.remove(id)
	}

	/**
	 * Removes the given ID, EObject pair from the registry if it has previously been registered.
	 */
	def unregister(String id, EObject obj) {
		uuidStore.remove(id, obj)
	}
}
