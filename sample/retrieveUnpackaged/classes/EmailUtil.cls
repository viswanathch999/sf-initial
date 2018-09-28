/* General purpose Email Utility Class with the following features:
 * Method chaining that construct and return an instance of a Email Util to 
 * save you the trouble of instantiating an EmailUtil when sending email.
 * Support templates. (whatId, templateId, targetObjectId)
 * Supports using a template or plaintext/html.
 * Bulk send functionality with the .stashForBulk() terminator and .sendBulkEmail() static method.
 * Verify emails sent during tests.   
 *
 * @author Naveen Hiremath
 **/
 
/*   
*********** Sending a Single Message ***********
Here's how you could compose a single email and send it immediately:
   
List<String>toAddresses = new List<String> {'john.doe@acme.org'};
String replyToAddress = 'john.duh@acme.org';

emailUtil.to(toAddresses)
    .plainTextBody('Bilbo Bagginses has stolen our Preciousssss!!')
    .senderDisplayName('Gollum Gollum')
    .replyTo(replyToAddress)
    .sendEmail();
           
           
*********** Sending Bulk Mail in a Trigger ***********
Here's a pseudo-code example of the bulk send inside a trigger:
   
triggeronContact on Contact (after insert) {
    for (Contact c : Trigger.new) {
        if (meets_criteria_for_send_email(c)) {
            EmailUtil.to(new String[]{'test@spam.com'})
                .stashForBulk();
        }
    }
    EmailUtil.sendBulkEmail();
}
*/

public class EmailUtil {
    /* ===================================
        Default settings for email content
    ======================================= */
    // defaults for email content 
    private String subject = '';
    private String htmlBody = '';
    private String plainTextBody = '';
    private Boolean useSignature = false;
    private Boolean SaveAsActivity = false;
    private List<Messaging.EmailFileAttachment>fileAttachments = null;
    // Default replyTo is current user's email address
    // using a static to save this result across multiple email constructions.
    private static User currentUser {
        get {
            if (currentUser == null)
                currentUser = [Select email from User where username = :UserInfo.getUserName() limit 1];
            return currentUser;
        } set;
    }
    private String replyTo = currentUser.email; //replyTo defaults to current user's email
    private String senderDisplayName = UserInfo.getFirstName()+' '+UserInfo.getLastName();
   
    // Template options
    private Id templateId;
    private Id whatId;
   
    // defaults for recipient types
    private Id targetObjectId; // Contact, Lead, or User.
    private final List<String>toAddresses;
   
    // Used to temporarily hold the email during the build command
    private Messaging.SingleEmailMessage singleEmailMessage;
   
   
       
    /* ===================================
        Chain Starters
    ======================================= */
    public static EmailUtil to(List<String> addresses) {
        return new EmailUtil(addresses);
    }
   
    public static EmailUtil to(Id target) {
        // warning: can't override this with a string handler, apex can't tell an Id from a String.
        return new EmailUtil(target);
    }
   
    /* ===================================
        Attribute Setters
    ======================================= */
   
    /*
    .saveAsActivity(Boolean val)
    .senderDisplayName(String val)
    .subject(String val)
    .htmlBody(String val)
    .useSignature(Boolean bool)
    .replyTo(String val)
    .plainTextBody(String val)
    .fileAttachments(List<Messaging.Emailfileattachment>val)
   
    for use in template:
    .templateId(Id an_id)
    .whatId(Id an_id)
    */
   
    public EmailUtil saveAsActivity(Boolean val) {
        saveAsActivity = val;
        return this;
    }
   
    public EmailUtil senderDisplayName(String val) {
        senderDisplayName = val;
        return this;
    }
   
    public EmailUtil subject(String val) {
        subject = val;
        return this;
    }
   
    public EmailUtil htmlBody(String val) {
        htmlBody = val;
        return this;
    }
   
    public EmailUtil templateId(Id an_id) {
        templateId = an_id;
        return this;
    }
   
    public EmailUtil whatId (Id an_id) {
        whatId = an_id;
        return this;
    }
   
    public EmailUtil targetObjectId (Id an_id) {
        targetObjectId = an_id;
        return this;
    }
   
    public EmailUtil useSignature(Boolean bool) {
        useSignature = bool;
        return this;
    }
   
    public EmailUtil replyTo(String val) {
        replyTo = val;
        return this;
    }
   
    public EmailUtil plainTextBody(String val) {
        plainTextBody = val;
        return this;
    }
   
    public EmailUtil fileAttachments(List<Messaging.Emailfileattachment>val) {
        fileAttachments = val;
        return this;
    }
   
    /* ===================================
        Chain Terminators: call to send now or stash for bulk send.
    ======================================= */
    public void sendEmail() {
        // build and send email.
        build();
        last_sendEmail_result = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { singleEmailMessage });
    }
    public void stashForBulk() {
        //build and stash email.
        build();
        bulk_stash.add(singleEmailMessage);
    }
   
    /* ===================================
        Other Bulk Actions
    ======================================= */
   
    public static void sendBulkEmail() {
        // send emails in bulk_stash, empty it.
        last_sendEmail_result = Messaging.sendEmail(bulk_stash);
        bulk_stash.clear();
    }
   
    public static Boolean hasEmailsToSend() {
        return bulk_stash.size() != 0 ? true : false;       
    }
   
    // static method for holding email results, so I can test when triggers send emails
    public static Messaging.SendEmailResult[] last_sendEmail_result {get; private set;}
   
   

    /* ===================================
        Helpers & private constructors
    ======================================= */

    // private constructors, force you to use the static chain methods.
    private EmailUtil(List<String> addresses) {
        this.toAddresses = addresses;
    }
   
    private EmailUtil(Id target) {
        this.targetObjectId = target;
    }
   
    // build method, constructs a single email message.
    // this method is private and is called from sendEmail() or stashForBulk()
    private EmailUtil build() {
        singleEmailMessage = new Messaging.SingleEmailMessage();
        singleEmailMessage.setTargetObjectId(this.targetObjectId);
        singleEmailMessage.setWhatId(this.whatId);
        singleEmailMessage.setToAddresses(this.toAddresses);
        singleEmailMessage.setSenderDisplayName(this.senderDisplayName);
        singleEmailMessage.setUseSignature(this.useSignature);
        singleEmailMessage.setReplyTo(this.replyTo);
        singleEmailMessage.setFileAttachments(this.fileAttachments);
        singleEmailMessage.setSaveAsActivity(this.saveasactivity);
        // use template if one exists, else use html and plain text body
        if (this.templateId == null) {
            singleEmailMessage.setHtmlBody(this.htmlBody);
            singleEmailMessage.setPlainTextBody(this.plainTextBody);
            singleEmailMessage.setSubject(this.subject);
        } else {
            singleEmailMessage.setTemplateId(this.templateId);
        }
        return this;
    }
   
    private static Messaging.SingleEmailMessage[] bulk_stash {
        get {
            if (bulk_stash == null)
                bulk_stash = new Messaging.SingleEmailMessage[]{};
            return bulk_stash;
        } private set;
    }
   
}