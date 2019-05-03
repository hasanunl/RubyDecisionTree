require 'csv'
require_relative 'decision_tree.rb'
require 'benchmark'
require 'memory_profiler'

def accuracy_metric(actual, predicted)
  correct = 0.0
  (0...actual.length).each do |i|
    if actual[i] == predicted[i]
      correct += 1
    end
  end
  correct / actual.length.to_f * 100
end

def evaluate_algorithm(dataset, n_folds, *args)
  folds = dataset
  scores = []
  split_point =folds.length / 4
  folds_clone = folds.clone
  train_set = folds_clone[0...(split_point*3)]
  test_set = folds.clone[(split_point*3)..(split_point*4)]
  # pp train_set
  predicted = decision_tree(train_set, test_set, *args)
  # pp predicted
  actual = []
  test_set.each do |row|
    actual << row[-1]
  end
  accuracy = accuracy_metric(actual, predicted)
  scores << accuracy
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
  evaluate_algorithm(dataset, n_folds, max_depth, min_size)
end

report.pretty_print
