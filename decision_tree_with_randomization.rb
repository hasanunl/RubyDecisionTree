require 'csv'
require_relative 'decision_tree.rb'
require 'benchmark'
require 'memory_profiler'

def cross_validation_split(dataset, n_folds)
  dataset_split = []
  dataset_copy = dataset.to_a
  fold_size = (dataset.length / n_folds).to_i
  rand_value = dataset_copy.length
  (0...n_folds).each do |i|
    fold = []
    while fold.length < fold_size
      index = $rnd.rand(rand_value)
      rand_value -= 1
      fold << dataset_copy[index]
      dataset_copy.pop[index]
    end
    dataset_split << fold
  end
  dataset_split
end

def accuracy_metric(actual, predicted)
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
    train_set = folds.clone.to_a
    train_set.delete(fold)
    train_set = train_set.flatten(1)
    test_set = []
    fold.clone.each do |row|
      row_copy = row.clone
      test_set << row_copy
      row_copy[-1] = nil
    end
    # pp train_set
    predicted = decision_tree(train_set, test_set, *args)

    # pp predicted
    actual = []
    fold.each do |row|
      actual << row[-1]
    end
    accuracy = accuracy_metric(actual, predicted)
    scores << accuracy
  end
  scores
end

def decision_tree(train, test, max_depth, min_size)
  dt = DecisionTree.new
  tree = dt.build_tree(train.clone, max_depth, min_size)
  predictions = []
  test.each do |row|
    prediction = dt.predict(tree, row)
    predictions << prediction
  end
  predictions
end

$rnd = Random.new(1)

# dataset = CSV.read('data_banknote_authentication.csv', converters: [CSV::Converters[:float]])

dataset = CSV.read('sonar.all-data.csv', converters: [CSV::Converters[:float]])

def str_column_to_int(dataset, column)
  class_values = []
  dataset.each do |row|
    class_values << row[column]
  end
  unique = class_values.uniq
  lookup = Hash.new
  unique.each_with_index { |item, index|
    lookup[item] = index
  }
  dataset.each do |row|
    row[column] = lookup[row[column]]
  end
  dataset
end

dataset = str_column_to_int(dataset, dataset[0].length - 1)

n_folds = 5
max_depth = 5
min_size = 10
scores = evaluate_algorithm(dataset.clone, n_folds, max_depth, min_size)
puts "Scores: #{scores}"
puts "Mean accuracy: #{scores.sum/scores.length.to_f}"
pp dataset[0].length
puts '***********************************************'

Benchmark.bm do |x|
  x.report { evaluate_algorithm(dataset.clone, n_folds, max_depth, min_size) }
end

puts '***********************************************'

report = MemoryProfiler.report do
  evaluate_algorithm(dataset, n_folds, max_depth, min_size)
end

report.pretty_print
