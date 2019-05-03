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
    fold.each do |row|
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
  tree = dt.build_tree(train, max_depth, min_size)
  predictions = []
  test.each do |row|
    prediction = dt.predict(tree, row)
    predictions << prediction
  end
  predictions
end

$rnd = Random.new(1)

dataset = []

CSV.foreach('data_banknote_authentication.csv', { converters: :float}) do |row|
  dataset << row
end

# dataset = CSV.read('data_banknote_authentication.csv', converters: [CSV::Converters[:float]])
#
n_folds = 5
max_depth = 5
min_size = 10
scores = evaluate_algorithm(dataset, n_folds, max_depth, min_size)
puts "Scores: #{scores}"
puts "Mean accuracy: #{scores.sum/scores.length.to_f}"

puts '***********************************************'

Benchmark.bm do |x|
  x.report { evaluate_algorithm(dataset, n_folds, max_depth, min_size) }
end

puts '***********************************************'

report = MemoryProfiler.report do
  evaluate_algorithm(dataset, 5, 5, 10)
end

report.pretty_print
