/**
 * DAO Factory allows us to abstract the process of finding 
 * an appropriate persistence mechanism away from the business/presentation 
 * components.
 * 
 * DAOStrategyFactory encapsulates the logic needed to decide the concrete class 
 * to instantiate
 *
 * @author Naveen Hiremath
 */
public class DAOStrategyFactory {

    /**
     * Factory method whose sole purpose is to build and 
     * return a DAOStrategy instance
     *  
     * @param daoType type of DAO that needs to be instantiated
     * @param sObjectType type of sObject to associate to
     * @return an instance of concrete SObject model
     */
    public static DAOStrategy getInstance(final DAOStrategyType daoType, 
                                          final Schema.sObjectType sObjectType) {
        DAOStrategy dataAccessMode;
        
        // Cannot use reflection since Type class's newInstance does not support
        // parameterized constructor instantiation
        if(daoType.name().equalsIgnoreCase(DAOStrategyType.DMLDAOStrategy.name())) {
            dataAccessMode = new DMLDAOStrategy(sObjectType);
        } else if(daoType.name().equalsIgnoreCase(DAOStrategyType.DatabaseDAOStrategy.name())){
            dataAccessMode = new DatabaseDAOStrategy(sObjectType);
        }
        
        return dataAccessMode;
    }
    
}