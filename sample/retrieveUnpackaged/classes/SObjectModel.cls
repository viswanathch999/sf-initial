/**
 * Model represents the concepts of the underlying 
 * custom and standard Salesforce objects.
 * 
 * SObjectModel is an abstract data-centric class that encapsulates 
 * state & behavior of closley related items needed across various contexts.
 * 
 * @author Naveen Hiremath
 */
public abstract class SObjectModel {

    /** Immutable reference to sobject */
    public final Sobject record { get; private set; }
    private final Schema.DescribeSObjectResult SObjectDescribe;
    
    public SObjectModel(final SObject sobj) { 
        if(sobj == null) {
            throw new ModelException('System.Label.Model_Initialization_Exception');
        }
        this.record = sobj;
        this.SObjectDescribe = this.record.getSObjectType().getDescribe();
    }
    
    /**
     * Checks if the record has been commited to the Database by checking
     * for its unique ID attribute
     *
     * @return Boolean
     */
    public Boolean isCommitted() {
        return (this.record.Id != null);
    }
    
    /**
     * Serializes the record into JSON format
     *
     * @return String
     */
    public String toJSON() {
        return System.JSON.serialize(this.record);
    }
    
    /**
     * String format of the record
     *
     * @return String
     */
    public override String toString() {
        return String.valueOf(this.record);  
    }
    
    /** General exception class for the Model layer */
    public class ModelException extends Exception {}
    
}