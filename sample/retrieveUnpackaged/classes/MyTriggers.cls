public class MyTriggers {
	/* Enum representing all the contexts available */
	public enum Evt {
		afterDelete, afterInsert, afterUndelete, afterUpdate, beforeDelete, beforeInsert, beforeUpdate
	}

	public interface Handler {
		void handle();
	}

	//Internal Mapping of handlers
	Map<String, List<Handler>> eventHandlerMapping = new Map<String, List<Handler>> ();

	public MyTriggers attach(Evt event, Handler handler) {
		List<Handler> handlers = eventHandlerMapping.get(event.name());
		if (handlers == null) {
			handlers = new List<Handler> ();
			eventHandlerMapping.put(event.name(), handlers);
		}
		handlers.add(handler);
		return this;
	}

	public void run() {
		Evt ev = null;
		if (Trigger.isInsert && Trigger.isBefore) {
			ev = Evt.beforeinsert;
		} else if (Trigger.isInsert && Trigger.isAfter) {
			ev = Evt.afterinsert;
		} else if (Trigger.isUpdate && Trigger.isBefore) {
			ev = Evt.beforeupdate;
		} else if (Trigger.isUpdate && Trigger.isAfter) {
			ev = Evt.afterupdate;
		} else if (Trigger.isDelete && Trigger.isBefore) {
			ev = Evt.beforedelete;
		} else if (Trigger.isDelete && Trigger.isAfter) {
			ev = Evt.afterdelete;
		} else if (Trigger.isundelete) {
			ev = Evt.afterundelete;
		}

		List<Handler> handlers = eventHandlerMapping.get(ev.name());
		if (handlers != null && !handlers.isEmpty()) {
			for (Handler h : handlers) {
				h.handle();
			}
		}
	}
}