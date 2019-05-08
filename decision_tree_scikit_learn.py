#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri May  3 15:21:53 2019

@author: hsn1997
"""

from csv import reader
from memory_profiler import profile


@profile

# Load a CSV file
def load_csv(filename):
    file = open(filename, "r")
    lines = reader(file)
    dataset = list(lines)
    return dataset

# Convert string column to float
def str_column_to_float(dataset, column):
    for row in dataset:
        row[column] = float(row[column].strip())

# Calculate accuracy percentage
def accuracy_metric(actual, predicted):
    correct = 0
    for i in range(len(actual)):
        if actual[i] == predicted[i]:
            correct += 1
    return correct / float(len(actual)) * 100.0

# Evaluate an algorithm using a cross validation split
def evaluate_algorithm(X, Y, algorithm, n_folds, *args):    
    predicted = algorithm(X, Y, test_set, *args)
    actual = [row[-1] for row in test_set]
    accuracy = accuracy_metric(actual, predicted)
    scores.append(accuracy)
    return scores

# Classification and Regression Tree Algorithm
def decision_tree(X, Y, test, max_depth, min_size):
    from sklearn import tree
    clf = tree.DecisionTreeClassifier()
    scores = list()
    split_point = int(len(X) / 4)
    X_train = X[0:(split_point*3)]
    X_test = X[((split_point*3)-1):(split_point*4)]
    Y_train = Y[0:(split_point*3)]
    Y_test = Y[((split_point*3)-1):(split_point*4)]
    tree = clf.fit(X_train, Y_train)
    predictions = list()
    for row in X_test:
        Y_pred =  clf.predict(X_test) 
        predictions.append(Y_pred)
    return(predictions)


def decision_tree_test():
    #Libraires
    import numpy as np
    import pandas as pd
    # load and prepare data
    filename = 'data_banknote_authentication.csv'
    dataset = pd.read_csv(filename)
    X = dataset.iloc[:,[2,3]].values
    Y = dataset.iloc[:,4].values
    # convert string attributes to integers
    for i in range(len(dataset[0])):
        str_column_to_float(dataset, i)
    # evaluate algorithm
    n_folds = 5
    max_depth = 5
    min_size = 10
    scores = evaluate_algorithm(X, Y, decision_tree, n_folds, max_depth, min_size)
    print('Scores: %s' % scores)
    print('Mean Accuracy: %.3f%%' % (sum(scores)/float(len(scores))))

if __name__ == '__main__':
    import timeit
    print(timeit.timeit("decision_tree_test()", setup="from __main__ import decision_tree_test", number=1))


