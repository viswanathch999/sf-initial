public with sharing class EventServices {
	
	public static void validateDeleteAllowed(List<Event> oldEvents){
        for (Event oldEvent : oldEvents)      
       {            
          if (!oldEvent.Able_to_Delete_Activities__c)
          {
             oldEvent.addError(Label.Cant_Delete_Task);
          }
       }
    }
}