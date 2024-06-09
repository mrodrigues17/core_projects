import numpy as np
from collections import Counter

class MachineLearningScratch:
    def __init__(self):
        self.decision_tree = None
        self.linear_regression_model = None
    
    # Decision Tree Methods
    class DecisionTree:
        def __init__(self, max_depth=None, min_samples_split=2, criterion='entropy'):
            self.max_depth = max_depth
            self.min_samples_split = min_samples_split
            self.criterion = criterion
            self.tree = None

        def fit(self, X, y):
            print("Fitting the decision tree...")
            self.tree = self._build_tree(X, y)
            print("Tree built:", self.tree)

        def _build_tree(self, X, y, depth=0):
            num_samples, num_features = X.shape
            unique_classes = np.unique(y)

            if len(unique_classes) == 1 or num_samples < self.min_samples_split or (self.max_depth and depth >= self.max_depth):
                leaf_value = self._most_common_label(y)
                print(f"Creating leaf node with value: {leaf_value}")
                return self.Node(value=leaf_value)

            best_feature, best_threshold = self._best_split(X, y, num_samples, num_features)
            left_idxs, right_idxs = self._split(X[:, best_feature], best_threshold)

            left = self._build_tree(X[left_idxs, :], y[left_idxs], depth + 1)
            right = self._build_tree(X[right_idxs, :], y[right_idxs], depth + 1)
            print(f"Creating internal node: feature {best_feature}, threshold {best_threshold}")
            return self.Node(best_feature, best_threshold, left, right)

        def _best_split(self, X, y, num_samples, num_features):
            best_gain = -1
            split_idx, split_threshold = None, None
            for feature_idx in range(num_features):
                X_column = X[:, feature_idx]
                thresholds = np.unique(X_column)
                for threshold in thresholds:
                    gain = self._information_gain(y, X_column, threshold)
                    if gain > best_gain:
                        best_gain = gain
                        split_idx = feature_idx
                        split_threshold = threshold
            return split_idx, split_threshold

        def _information_gain(self, y, X_column, threshold):
            if self.criterion == 'gini':
                parent_impurity = self._gini(y)
            else:
                parent_impurity = self._entropy(y)

            left_idxs, right_idxs = self._split(X_column, threshold)
            if len(left_idxs) == 0 or len(right_idxs) == 0:
                return 0

            num_samples = len(y)
            num_left, num_right = len(left_idxs), len(right_idxs)

            if self.criterion == 'gini':
                impurity_left = self._gini(y[left_idxs])
                impurity_right = self._gini(y[right_idxs])
            else:
                impurity_left = self._entropy(y[left_idxs])
                impurity_right = self._entropy(y[right_idxs])

            child_impurity = (num_left / num_samples) * impurity_left + (num_right / num_samples) * impurity_right
            ig = parent_impurity - child_impurity
            return ig

        def _split(self, X_column, split_threshold):
            left_idxs = np.argwhere(X_column <= split_threshold).flatten()
            right_idxs = np.argwhere(X_column > split_threshold).flatten()
            return left_idxs, right_idxs

        def _entropy(self, y):
            hist = np.bincount(y)
            ps = hist / len(y)
            return -np.sum([p * np.log2(p) for p in ps if p > 0])

        def _gini(self, y):
            """
            Function to calculate Gini impurity at a node
            Steps:
                1. 
            
            """
            hist = np.bincount(y)
            ps = hist / len(y)
            return 1 - np.sum([p**2 for p in ps])

        def _most_common_label(self, y):
            return np.bincount(y).argmax()

        def predict(self, X):
            print("Predicting...")
            predictions = np.array([self._traverse_tree(x, self.tree) for x in X])
            print("Predictions:", predictions)
            return predictions

        def _traverse_tree(self, x, node):
            """
            Function to traverse the tree
            """
            print(f"Traversing node: {node}")
            if node.is_leaf_node():
                print(f"Reached leaf node: {node.value}")
                return node.value
            if x[node.feature] <= node.threshold:
                print(f"Going left: x[{node.feature}] <= {node.threshold}")
                return self._traverse_tree(x, node.left)
            print(f"Going right: x[{node.feature}] > {node.threshold}")
            return self._traverse_tree(x, node.right)

        class Node:
            def __init__(self, feature=None, threshold=None, left=None, right=None, *, value=None):
                self.feature = feature
                self.threshold = threshold
                self.left = left
                self.right = right
                self.value = value

            def is_leaf_node(self):
                return self.value is not None

    class LinearRegression:
        def __init__(self):
            self.learning_rate = .00001
            self.max_iter = 1000
            self.intercept = None
            self.coefs = None

        def _lr_cost_deriv(self, X, theta, j, y):
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

        def _lr_gradient_descent(self, X, y):
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
            theta_temp = np.array([0.0 for i in range(X.shape[1])])
            for i in range(self.max_iter):
                for j in range(len(theta)):
                    theta_temp[j] = theta[j] - self.learning_rate * (1 / len(y)) * self._lr_cost_deriv(X, theta, j, y)
                theta = theta_temp
            self.intercept = theta[0]
            self.coefs = theta[1:]

        def fit(self, X, y):
            """
            Takes a set of features X and numeric target vector y and performs gradient descent to minimize the loss function
            """

            X_with_intercept = np.insert(X, 0, 1, axis=1)
            self._lr_gradient_descent(X_with_intercept, y)

        def predict(self, X):
            """
            Takes the coefficients and intercept of the linear regression model and predicts the target values for the given input features X.
            """
            X_with_intercept = np.insert(X, 0, 1, axis=1)
            return np.dot(X_with_intercept, np.insert(self.coefs, 0, self.intercept))

    # Decision Tree Interface
    def fit_decision_tree(self, X, y, max_depth=None, min_samples_split=2):
        self.decision_tree = self.DecisionTree(max_depth, min_samples_split)
        self.decision_tree.fit(X, y)

    def predict_decision_tree(self, X):
        if self.decision_tree is not None:
            return self.decision_tree.predict(X)
        else:
            raise ValueError("Decision tree model has not been trained yet.")

    # Linear Regression Interface
    def fit_linear_regression(self, X, y):
        self.linear_regression_model = self.LinearRegression()
        self.linear_regression_model.fit(X, y)

    def predict_linear_regression(self, X):
        if self.linear_regression_model is not None:
            return self.linear_regression_model.predict(X)
        else:
            raise ValueError("Linear regression model has not been trained yet.")
