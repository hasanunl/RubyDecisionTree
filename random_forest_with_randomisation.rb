require 'csv'
require_relative 'random_forest_decision_tree'
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
  correct = 0.0
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
    predicted = random_forest(train_set, test_set, *args)
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

def subsample(dataset, ratio)
  sample = []
  n_sample = (dataset.length * ratio).to_f.round
  while sample.length < n_sample
    index = $rnd.rand(dataset.length)
    sample << dataset.clone[index]
  end
  sample
end

def bagging_predict(trees, row)
  rf_dt = RandomForestDecisionTree.new
  predictions = []
  trees.each do |tree|
    prediction = rf_dt.predict(tree, row)
    predictions << prediction
  end
  predictions.uniq.max_by { |x| predictions.count }
end

def random_forest(train, test, max_depth, min_size, sample_size, n_trees, n_features, rnd)
  rf_dt = RandomForestDecisionTree.new
  trees = []
  (0...n_trees).each do |i|
    sample = subsample(train, sample_size)
    tree = rf_dt.build_tree(sample, max_depth, min_size, n_features, rnd)
    trees << tree
  end
  predictions = []
  test.each do |row|
    prediction = bagging_predict(trees, row)
    predictions << prediction
  end
  predictions
end

$rnd = Random.new(2)

dataset = []

CSV.foreach('data_banknote_authentication.csv', { converters: :float}) do |row|
  dataset << row
end

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

# dataset = str_column_to_int(dataset, dataset[0].length - 1)

def random_forest_with_randomization(dataset)
  n_folds = 5
  max_depth = 10
  min_size = 1
  sample_size = 1.0
  n_features = dataset[0].length - 1
  n_features = Math.sqrt(n_features).to_i
  [5].each do |n_trees|
    scores = evaluate_algorithm(dataset.clone, n_folds.clone, max_depth, min_size, sample_size, n_trees, n_features, $rnd)
    puts "Trees: #{n_trees}"
    puts "Scores: #{scores}"
    puts "Mean accuracy: #{scores.sum/scores.length.to_f}"
  end
end

puts '***********************************************'

Benchmark.bm do |x|
  x.report { random_forest_with_randomization(dataset) }
end

puts '***********************************************'

report = MemoryProfiler.report do
  random_forest_with_randomization(dataset)
end

report.pretty_print