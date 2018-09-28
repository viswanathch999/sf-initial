/**
 * DAOStrategyType represents all the concrete implementations of DAOStrategy
 *
 * @author Naveen Hiremath
 */
public enum DAOStrategyType {
     /** Concrete class that uses DML statements */
    DMLDAOStrategy,
    /** Concrete class that uses Database methods */
    DatabaseDAOStrategy
}