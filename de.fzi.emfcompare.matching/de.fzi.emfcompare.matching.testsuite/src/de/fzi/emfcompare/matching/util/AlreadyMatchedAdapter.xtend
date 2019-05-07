package de.fzi.emfcompare.matching.util

import org.eclipse.emf.common.notify.Adapter
import org.eclipse.emf.common.notify.Notification
import org.eclipse.emf.common.notify.Notifier

/** Trivial implementation of {@link Adapter} which is used to tag 
 *  already matched objects in any of the {@link EmfTagExtensions}. 
 */
class AlreadyMatchedAdapter implements Adapter {
	
	override getTarget() { null }
	
	override isAdapterForType(Object arg0) {false}
	
	override notifyChanged(Notification arg0) { }
	
	override setTarget(Notifier arg0) { }
	
}