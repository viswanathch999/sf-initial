/**
 * SObjectModelMock is a concrete implementation of SObjectModel used solely 
 * for the purpose of unit testing
 * 
 * @author Naveen Hiremath
 */
@isTest
public class SObjectModelMock extends SObjectModel {
     public SObjectModelMock(final SObject sobj) {
            super(sobj);
     }
}