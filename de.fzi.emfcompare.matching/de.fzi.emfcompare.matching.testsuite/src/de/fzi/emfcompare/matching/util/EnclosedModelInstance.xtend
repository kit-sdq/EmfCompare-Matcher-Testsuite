package de.fzi.emfcompare.matching.util

import de.fzi.emfcompare.matching.util.SimpleUuidResolver
import java.util.NoSuchElementException
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.resource.ResourceSet
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl
import static extension de.fzi.emfcompare.matching.util.EmfCompareExtensions.getUri

/**
 * Wraps an EMF model and provides methods for resolving and traversing objects of the wrapped model
 * 
 */
class EnclosedModelInstance {
	EObject root
	String pathDelimiter
	String pathAttribute
	ResourceSet resource = new ResourceSetImpl
	SimpleUuidResolver resolver = new SimpleUuidResolver
	boolean resolverInitialized = false

	/**
	 * Wraps the model at the given URI and sets the default path delimiter and path attribute to '/' and 'name' for future model queries.
	 */
	new(URI uri) {
		this(uri, "/", "name")
	}

	/**
	 * Wraps the model at the given URI and sets the default path delimiter and path attribute for future model queries.
	 */
	new(URI uri, String pathDelimiter, String pathAttribute) {
		resource.getResource(uri, true)
		root = resource.resources.get(0).contents.get(0);
		this.pathDelimiter = pathDelimiter
		this.pathAttribute = pathAttribute
	}

	/**
	 * Returns the root element of the wrapped model 
	 */
	def getRoot() {
		root
	}

	/**
	 * Finds an element of the model by it's universally unique id
	 */
	def find(String id) {
		if (!resolverInitialized) {
			resolver.register(root.eAllContents)
			resolver.register(root)
			resolverInitialized = true
		}
		resolver.find(id)
	}

	/**
	 * Finds an element of the model by it's Uniform Resource Identifier (URI)
	 */
	def find(URI uri) {
		if(uri === null) return null
		resource.getEObject(uri, true)
	}

	/**
	 * Finds an element of the model by following a path from a specific start element
	 */
	def EObject resolveElement(EObject from, String _path) {
		if(_path === null) return from;
		if(from === null) return null

		// Remove trailing delimiter
		val path = if (_path != pathDelimiter && _path.endsWith(pathDelimiter))
				_path.substring(0, _path.length - pathDelimiter.length)
			else
				_path

		val next = path.split(pathDelimiter).get(0) ?: path as String

		switch next {
			// Handling special cases '.', '' and '..'
			case ".",
			case "": {
				if (path.contains(pathDelimiter))
					return resolveElement(from, path.split(pathDelimiter).stream.skip(1).toArray.fold("", [ s, t |
						s + pathDelimiter + t
					]).substring(1))
				else
					return from
			}
			case "..": {
				if(from.uri == root.uri) return from
				if (path.contains(pathDelimiter))
					return resolveElement(
						from.eContainer,
						path.split(pathDelimiter).stream.skip(1).toArray.fold("", [s, t|s + pathDelimiter + t]).
							substring(1)
					)
				else
					return from.eContainer
			}
			default: {
				// parse feature name and feature value from the next path segment
				val name = parseFragmentName(next)
				val featureName = parseFragmentFeature(next)
				// search all structural features of child elements for matching names and values 
				var all = from.eContents
				var found = all.filter [
					var feature = eClass.getEStructuralFeature(featureName);
					feature !== null && eGet(feature) instanceof String && name.equals((eGet(feature) as String))
				]
				if(found.
					empty) throw new NoSuchElementException('''No element with name='«next»' was found at entity «from»!''')

				if (path.contains(pathDelimiter))
					return resolveElement(found.get(0), path.split(pathDelimiter).stream.skip(1).toArray.fold("", [ s, t |
						s + pathDelimiter + t
					]).substring(1))
				else
					return found.get(0)
			}
		}
	}

	/**
	 * Finds an element of the model by following a path from the root element of the model
	 */
	def resolveElement(String path) {
		resolveElement(root, path)
	}

	/**
	 * Parse name from path fragment.
	 * Example: frag = "@identifier=123456"
	 * Result: 123456
	 */
	private def String parseFragmentName(String frag) {
		if (frag.matches("^@\\w*=.*$"))
			frag.substring(frag.indexOf("=") + 1)
		else
			frag
	}

	/**
	 * Parse StructuralFeature name from path fragment.
	 * Example: frag = "@identifier=123456"
	 * Result: identifier
	 */
	private def String parseFragmentFeature(String frag) {
		if (frag.matches("^@\\w*=.*$"))
			frag.substring(1, frag.indexOf("="))
		else
			pathAttribute
	}
}
