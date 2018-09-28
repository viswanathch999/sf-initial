public class ProfileCompletionUtility {
	public static void ProfileCompletionUtility(Map<Id, String> updatedCriteria) {
		Map<String, Schema.SObjectField> criteriaFields = Schema.SObjectType.Profile_Completion_Criteria__c.fields.getMap();
		Map<String, List<String>> criteriaMap = new Map<String, List<String>> ();

		Try {
			Map<Id, Contact_Profile_Completion__c> existingPercentageMap = new Map<Id, Contact_Profile_Completion__c> ();
			List<Contact_Profile_Completion__c> updatedPercentages = new List<Contact_Profile_Completion__c> ();
			Map<Id, String> contactType = new Map<Id, String> ();

			for (Contact c :[Select Id, RecordType.Name, YPO_WPO_Formula__c FROM Contact WHERE Id IN :updatedCriteria.keySet()]) {
				if (String.valueOf(c.RecordType.Name) != 'Member') {
					contactType.put(c.Id, c.RecordType.Name);
				} else {
					contactType.put(c.Id, c.YPO_WPO_Formula__c);
				}

			}

			String profileQuery = 'Select ';
			List<String> criteriaList;
			for (String pName : contactType.values()) {
				criteriaList = new List<String> ();
				if (Profile_Completion_Criteria__c.getInstance(pName) != NULL) {
					Profile_Completion_Criteria__c pComp = Profile_Completion_Criteria__c.getInstance(pName);
					for (String s : criteriaFields.keySet()) {
						if (Schema.SObjectType.Profile_Completion_Criteria__c.fields.getMap().get(s).getDescribe().isCustom()) {
							System.debug('Query: ' + profileQuery + ' ' + s);
							if (!profileQuery.contains(' ' + s)) {
								profileQuery += s + ', ';
							}
							if (Integer.valueOf(pComp.get(s)) > 0) {
								criteriaList.add(s);
							}
						}
					}
					System.debug('Criteria Fields: ' + pName  + ' ' + criteriaFields);
					criteriaMap.put(pName, criteriaList);
				}
			}

			String whereString = '(';

			for (Id s : updatedCriteria.keySet()) {
				whereString += '\'' + String.valueOf(s) + '\',';
			}

			whereString = whereString.removeEnd(',');

			profileQuery += ' Contact__c From Contact_Profile_Completion__c where Contact__c IN ' + whereString + ')';
			for (Contact_Profile_Completion__c contProfile : Database.query(profileQuery)) {
				existingPercentageMap.put(contProfile.Contact__c, contProfile);
			}

			Contact_Profile_Completion__c contProfile;
			for (Id i : updatedCriteria.keySet()) {
				if (existingPercentageMap.containsKey(i)) {
					contProfile = existingPercentageMap.get(i);
				} else {
					contProfile = new Contact_Profile_Completion__c();
					contProfile.contact__c = i;
				}

				Decimal countFilled = 0;
				Profile_Completion_Criteria__c updateCompletion = (Profile_Completion_Criteria__c) JSON.deserializeStrict(updatedCriteria.get(i), Profile_Completion_Criteria__c.class);
				
				for (String fieldName : criteriaFields.keySet()) {
					if (criteriaFields.get(fieldName).getDescribe().isCustom()) {

					Decimal percentCriteria = (Decimal) Profile_Completion_Criteria__c.getInstance(contactType.get(contProfile.Contact__c)).get(fieldName);

						if (criteriaMap.get(contactType.get(contProfile.Contact__c)).contains(fieldName) || percentCriteria< 0) {
							
							Decimal percentComplete = (Decimal) updateCompletion.get(fieldName);
							Decimal existingPercentage = ((Decimal) contProfile.get(fieldName));

							System.debug(fieldName + ' ' + percentCriteria + ' ' + percentComplete + ' ' + existingPercentage);

							System.debug((percentComplete == 1.0) + ' ' + (percentComplete == NULL) + ' ' + (percentComplete >= percentCriteria));

							if (percentComplete == 1.0){
								contProfile.put(fieldName, 100);
								countFilled++;
							} else if(existingPercentage == 100 && percentComplete == null) {
								countFilled++;
							} else if (percentCriteria < 0.0) {
								if (percentComplete == 1.0 || (existingPercentage == 100 && percentComplete == null)) {
									contProfile.put(fieldName, 100);
									countFilled++;
								} else if (percentComplete != null) {
									System.debug(fieldName + ' ' + percentCriteria + ' ' + percentComplete + ' ' + existingPercentage);
									contProfile.put(fieldName, (percentComplete / percentCriteria));
								} else {
									contProfile.put(fieldName, 0);
								}
							}else{
								contProfile.put(fieldName, 0);
							}


							//if (percentComplete < percentCriteria && percentComplete != NULL) {
							//contProfile.put(fieldName, (percentComplete / percentCriteria));
							//} else if ((percentComplete >= percentCriteria || percentComplete == 1.0) && percentCriteria > 0.0) {
							//contProfile.put(fieldName, 100);
							//countFilled++;
							//} else if(percentCriteria < 0.0){	

							//}						
						}
					}
				}
				System.debug('Completion Formula: (' + countFilled + ' / ' + criteriaMap.get(contactType.get(contProfile.Contact__c)).size() + ') * 100');
				contProfile.put('Completion_Percentage__c', (countFilled / criteriaMap.get(contactType.get(contProfile.Contact__c)).size()) * 100);
				System.debug('Completion Object: ' + contProfile);
				updatedPercentages.add(contProfile);
			}
			if (updatedPercentages.size()> 0) {
				upsert updatedPercentages;
			}

		} catch(Exception e) {
			System.debug(e.getMessage());
			System.debug(e.getLineNumber());
		}
	}
}