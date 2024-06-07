import numpy as np

class MachineLearningScratch:
    def linear_regression(self, X, y, learning_rate, max_iter):
        """
        Performs linear regression using gradient descent and returns the intercept and coefficients.
        Parameters
        ----------
        X: matrix
            The matrix of features
        y: array
            Array of targets
        learning_rate: float
            Indicates size of steps taken during gradient descent. Large values may not converge, small values will take longer
        max_iter: int
            The number of iterations of gradient descent to take
        Return
        ------
        intercept: float
            The intercept for the linear regression model
        coefs: array
            An array of coefficients that can be multiplied against the features
        """

        def lr_cost_func(X, theta, y):
            """Returns the cost function for linear regression
             Parameters
             ----------
                X: matrix
                    The features used for prediction
                theta: array
                    The coefficients multiplied against the features
                y: array
                    The actual target values
            Return
            ------
                cost: float
                    The value of the cost function for the given inputs
            """
            cost = (1 / (2 * len(y))) * sum((np.dot(X, theta) - y)**2)
            return cost

        def lr_cost_deriv(X, theta, j, y):
            """Calculates the derivative of the cost function for linear regression
             Parameters
             ----------
                X: matrix
                    The features used for prediction
                theta: array
                    An array of coefficients to optimize
                j: int
                    Iterator to indicate which feature to calculate the partial derivative for
                y: array
                    The target values
            Return
            ------
                gradient: float
                    The derivative of the cost function
            """    
            gradient = np.dot(np.dot(X, theta) - y, X[:, j])
            return gradient

        def lr_gradient_descent(X, y, learning_rate, max_iter):
            """
            Perfoms batch gradient descent algorithm and returns the optimized intercept and coefficients
            Parameters
            ----------
                X: matrix
                    The matrix of features
                y: array
                    Array of targets
                learning_rate: float
                    Indicates size of steps taken during gradient descent. Large values may not converge, small values will take longer
                max_iter: int
                    The number of iterations of gradient descent to take
            Return
            ------
                intercept: float
                    The intercept for the linear regression model
                coefs: aray
                    An array of coefficients that can be multiplied against the features
            """
            theta = np.array([0.0 for i in range(X.shape[1])])
            theta_temp = np.array([0.0 for i in range(X.shape[1])]) #initialize an array with zeros
            for i in range(max_iter): 
                for j in range(len(theta)):
                    theta_temp[j] = theta[j] - learning_rate * (1 / (len(y))) * lr_cost_deriv(X=X, theta=theta, j=j, y=y)
                theta = theta_temp
            intercept = theta[0]
            coefs = theta[1:]
            return intercept, coefs

        # Add a column of ones for the intercept
        X_with_intercept = np.insert(X, 0, 1, axis=1)
        
        # Perform gradient descent
        intercept, coefs = lr_gradient_descent(X_with_intercept, y, learning_rate, max_iter)
        
        return intercept, coefs