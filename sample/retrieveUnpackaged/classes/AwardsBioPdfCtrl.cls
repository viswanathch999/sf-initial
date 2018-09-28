public without sharing class AwardsBioPdfCtrl {
    
    public Contact member { get; set; }
	public Account chapter { get; set; }
	public Account region { get; set; }
	public Account_Affiliation__c business { get; set; }
    public Map<String, String> businessInfo { get; set; }
    public Map<String, String> personalInfo { get; set; }
    public List<Relationship__c> familyMembers { get; set; }
    
    public List<Contact_Position__c> committeePositions { get; set; }
    public List<Account_Affiliation__c> committeeMemberships { get; set; }
    public List<Contact_Position__c> chapterOfficers { get; set; }
    public List<Contact_Position__c> regionOfficers { get; set; }
    public List<Contact_Position__c> networkOfficers { get; set; }
    public List<Contact_Position__c> meetingsChampioned { get; set; }
    
    public List<Contact_Event__c> glcClwEvents { get; set; }
    public List<Contact_Event__c> nonChapterEvents { get; set; }
    public List<Contact_Event__c> fastTrackEvents { get; set; }
    public List<Contact_Event__c> gccEvents { get; set; }
    public List<Contact_Event__c> nonChapterComplexEvents { get; set; }
    public List<Contact_Event__c> regBoardMeetingEvents { get; set; }
    
    public List<Account_Affiliation__c> networkMemberships { get; set; }
    
    public List<Contact_Achievement__c> awards { get; set; }
    
    
    public AwardsBioPdfCtrl() { 
        
        //
        // Member Details
        //
        member = new Contact();
		chapter = new Account();
		region = new Account();
		business = new Account_Affiliation__c();
        try {
            member =   [SELECT Id, Name, LastName, FirstName, Middle_Name__c, Birthdate, Age_Current__c, Join_Date__c, Initial_Acceptance_Company__c, 
                               Email, Account.Name, Primary_Country__c, Biography__c, MailingStreet, MailingCity, MailingState, MailingCountry, 
                               MailingPostalCode, Phone, Phone_Extension__c, Country_Code__c, Fax, Fax_Country_Code__c, 
                               HomePhone, Home_Phone_Country_Code__c, Home_Phone_Extension__c, MobilePhone, Mobile_Phone_Country_Code__c
                        FROM Contact
                        WHERE Id = :ApexPages.currentPage().getParameters().get('id')
					    LIMIT 1];
			chapter =  [SELECT Id, Name, ParentId
					    FROM Account
					    WHERE Id = :member.AccountId
					    LIMIT 1]; 
			region =   [SELECT Id, Name
					    FROM Account
					    WHERE Id = :chapter.ParentId
					    LIMIT 1];
			business = [SELECT Id, Name, AccountName__c, IsActive__c, Is_Primary__c, Account_Type__c
						FROM Account_Affiliation__c
						WHERE Contact__c = :member.Id
						AND Account_Type__c = 'Business'
						AND IsActive__c = true
						AND Is_Primary__c = true
						LIMIT 1];
						
        }
        catch (Exception e) {
            system.debug('Error retrieving contact details: ' + e.getMessage() + ' @ line ' + e.getLineNumber());
        }
        
                
        //
        // Business Contact Info
        //
        businessInfo = new Map<String, String>();
        // Key prefix is used to sort values on the page (trimmed in Visualforce to display only the field name)
        businessInfo.put('01_Primary Business', business.AccountName__c == null ? '' : business.AccountName__c);
        businessInfo.put('02_Primary Email', member.Email == null ? '' : member.Email);
        businessInfo.put('03_Business Phone', formatPhone(member.Country_Code__c, member.Phone, member.Phone_Extension__c));
        businessInfo.put('04_Business Fax', formatPhone(member.Fax_Country_Code__c, member.Fax, null));
		String tmpAddr = member.MailingStreet + '<br/>' + member.MailingCity + ', ' + member.MailingState + ' ' + member.MailingPostalCode + '<br/>' + member.MailingCountry;
		businessInfo.put('05_Address', tmpAddr.remove('null'));
        
        
        //
        // Personal Contact Info
        //
        personalInfo = new Map<String, String>();
        personalInfo.put('01_Home Phone', formatPhone(member.Home_Phone_Country_Code__c, member.HomePhone, member.Home_Phone_Extension__c));
        personalInfo.put('02_Mobile Phone', formatPhone(member.Mobile_Phone_Country_Code__c, member.MobilePhone, null));
        
        
        //
        // Family Member Info
        //
        familyMembers = new List<Relationship__c>();
        List<Relationship__c> household = new List<Relationship__c>();
        try {
            // Get household account id based on member id
            household = [SELECT Id, Account__c, Contact__c
                         FROM Relationship__c
                         WHERE Contact__c = :member.Id
                         LIMIT 1];
            // Get list of family members based on relationships with household account id
            familyMembers = [SELECT Relationship_Type__c, Contact__r.Name, Account__c
                             FROM Relationship__c
                             WHERE Account__c = :household[0].Account__c
                             AND Relationship_Type__c != 'Member'
                             AND (Relationship_Type__c = 'Spouse/Partner' OR Relationship_Type__c = 'Child')
                             AND Is_Active__c = true];
        }
        catch (Exception e) {
            system.debug('Error retrieving family member information - ' + e.getMessage() + ' @ line ' + e.getLineNumber());
        }
        
        
        //
        // Contact Positions
        //
        committeePositions = new List<Contact_Position__c>();
        chapterOfficers = new List<Contact_Position__c>();
        regionOfficers = new List<Contact_Position__c>();
        networkOfficers = new List<Contact_Position__c>();
        meetingsChampioned = new List<Contact_Position__c>();
        for (Contact_Position__c cp : [SELECT Id, Contact__c, Account__r.Name, Position_Category__c, Position_Title__c, Start_Date__c, End_Date__c, Event_Text__c
                                        FROM Contact_Position__c
                                        WHERE Contact__c = :member.Id
                                        ORDER BY Start_Date__c ASC])
        {
            if (cp.Position_Category__c == 'Committee' && cp.Position_Title__c != 'Co-Chair') committeePositions.add(cp);
            if (cp.Position_Category__c == 'Chapter') chapterOfficers.add(cp);
            if (cp.Position_Category__c == 'Region') regionOfficers.add(cp);
            if (cp.Position_Category__c == 'Network' || cp.Position_Category__c == 'Sub-Network') networkOfficers.add(cp);
            if (cp.Position_Category__c == 'Event') meetingsChampioned.add(cp);
        }
        
        
        //
        // Account Affiliations
        //
        committeeMemberships = new List<Account_Affiliation__c>();
        networkMemberships = new List<Account_Affiliation__c>();
		for (Account_Affiliation__c af : [SELECT Id, Contact__c, AccountName__c, Job_Title__c, Account_Type__c, RecordType.DeveloperName, Start_Date__c, End_Date__c
											FROM Account_Affiliation__c
											WHERE Contact__c = :member.Id
											ORDER BY Start_Date__c ASC]) 
		{
			if (af.RecordType.DeveloperName == 'Committee' && (af.Account_Type__c == 'Event' || af.Account_Type__c == 'International')) committeeMemberships.add(af);
			if (af.RecordType.DeveloperName == 'Network') networkMemberships.add(af);
		}
        
        
        //
        // Contact Events
        //
        glcClwEvents = new List<Contact_Event__c>();
        nonChapterEvents = new List<Contact_Event__c>();
        nonChapterComplexEvents = new List<Contact_Event__c>();
        fastTrackEvents = new List<Contact_Event__c>();
        gccEvents = new List<Contact_Event__c>();
        regBoardMeetingEvents = new List<Contact_Event__c>();
		for (Contact_Event__c ce : [SELECT Id, Contact__c, Event_Name__c, Program_Format__c, Event__r.Start_Date__c, Event__r.End_Date__c
									FROM Contact_Event__c
									WHERE Contact__c = :member.Id
									AND Program_Format__c != 'Chapter Event'
									ORDER BY Event__r.Start_Date__c ASC])
		{
			if (ce.Program_Format__c == 'GLC/CLW') glcClwEvents.add(ce);
			if (ce.Program_Format__c == 'Non-Chapter Event') nonChapterEvents.add(ce);
			if (ce.Program_Format__c == 'Non-Chapter Event Complex') nonChapterComplexEvents.add(ce);
			if (ce.Program_Format__c == 'Fast Track Event') fastTrackEvents.add(ce);
			if (ce.Program_Format__c == 'Global Conference Call (GCC)') gccEvents.add(ce);
			if (ce.Program_Format__c == 'Regional Board Meeting') regBoardMeetingEvents.add(ce);
		}

        
        //
        // Contact Achievements
        //
        awards = new List<Contact_Achievement__c>();
		for (Contact_Achievement__c ca : [SELECT Id, Achievement_Name__c, YPO_Award_Year__c, Achievement_Category__c, RecordType.DeveloperName
										  FROM Contact_Achievement__c
										  WHERE Contact__c = :member.Id
										  ORDER BY YPO_Award_Year__c ASC])
		{
			if (ca.RecordType.DeveloperName == 'Award') awards.add(ca);
		}
        
    }
    
    
    // Correctly format phone number based on existence of country code, phone number, and extension
    public String formatPhone(String countryCode, String phoneNum, String phoneExt) {
        if (phoneNum != null) {
            if (countryCode != null) {
                if (phoneExt != null) return '+' + countryCode + ' ' + phoneNum + ' Ext. ' + phoneExt;
                else return '+' + countryCode + ' ' + phoneNum;
            }
            else {
                if (phoneExt != null) return phoneNum + ' Ext. ' + phoneExt;
                else return phoneNum;
            }
        }
        else {
            return '';
        }
        
    }
    
}