require 'csv'
require_relative 'decision_tree.rb'

def cross_validation_split(dataset, n_folds)
  rnd = Random.new(1)
  dataset_split = []
  dataset_copy = dataset.to_a
  fold_size = (dataset.length / n_folds).to_i
  rand_value = dataset_copy.length
  (0...n_folds).each do |i|
    fold = []
    while fold.length < fold_size
      index = rnd.rand(rand_value)
      rand_value -= 1
      fold << dataset_copy[index]
      dataset_copy.pop[index]
    end
    dataset_split << fold
  end
  dataset_split
end

def accuracy_metric(actual, predicdect)
  correct = 0
  (0...actual.length).each do |i|
    if actual[i] == predicted[i]
      correct += 1
    end
  end
  correct / actual.length.to_f * 100
end

def evaluate_algorithm(dataset, n_folds, *args)
  folds = cross_validation_split(dataset, n_folds)
  scores = []
  folds.each do |fold|
    train_set = folds
    train_set.delete(fold)
    # concat part
    test_set = []
    fold.each do |row|
      row_copy = row.to_a
      test_set << row_copy
      row_copy[-1] = nil
    end
    predicted = decision_tree(train_set, test_set, *args)
    actual = []
    fold.each do |row|
      actual << row[-1]
    end
    accuracy = accuracy_metric(actual, predicted)
    scores << accuracy
  end
  return scores
end

def decision_tree(train, test, max_depth, min_size)
  dt = DecisionTree.new
  dt.build_tree(train, max_depth, min_size)
  predictions = []
  test.each do |row|
    prediction = dt.predict(tree, row)
    predictions << prediction
  end
  predictions
end


dataset = [[2.771244718,1.784783929,0],
           [1.728571309,1.169761413,0],
           [3.678319846,2.81281357,0],
           [3.961043357,2.61995032,0],
           [2.999208922,2.209014212,0],
           [7.497545867,3.162953546,1],
           [9.00220326,3.339047188,1],
           [7.444542326,0.476683375,1],
           [10.12493903,3.234550982,1],
           [6.642287351,3.319983761,1]]

dt = DecisionTree.new

split = dt.get_split(dataset)
tree = dt.build_tree(dataset, 1, 1)
# pp tree
# gi_2 = gini_index([[[1, 0], [1, 0]], [[1, 1], [1, 1]]], [0, 1])
# pp gi_2
stump = {index: 0, right: 1, value: 6.642287351, left: 0}
dataset.each do |row|
  prediction = dt.predict(stump, row)
  puts "Expected #{row[-1]}, got #{prediction}"
end



dataset = CSV.read('data_banknote_authentication.csv', converters: [CSV::Converters[:float]])
n_folds = 5
max_depth = 5
min_size = 10
scores = evaluate_algorithm(dataset, n_folds, max_depth, min_size)
# puts "Scores: #{scores}"
# puts "Mean accuracy: #{scores.sum/scores.length.to_f}"
