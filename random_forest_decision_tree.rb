class RandomForestDecisionTree
  def test_split(index, value, dataset)
    left, right = [], []
    dataset.each do |row|
      if row[index] < value
        left.append(row)
      else
        right.append(row)
      end
    end
    return left, right
  end

  def get_split(dataset, n_features, rnd)
    dataset_rows = []
    dataset.each do |row|
      dataset_rows.append(row[-1])
    end
    class_values = dataset_rows.uniq
    b_index, b_value, b_score, b_groups = 999, 999, 999, nil
    features = []
    while features.length < n_features
      index = rnd.rand(dataset[0].length - 1)
      unless features.include?(index)
        features << index
      end
    end
    features.each do |index|
      dataset.each do |row|
        groups = test_split(index, row[index], dataset)
        gini = gini_index(groups, class_values)
        if gini < b_score
          b_index, b_value, b_score, b_groups = index, row[index], gini, groups
        end
      end
    end
    { index: b_index, value: b_value, groups: b_groups }
  end

  def gini_index(groups, classes)
    n_instances = 0.0
    groups.each do |group|
      n_instances += group.size
    end
    gini = 0.0
    groups.each do |group|
      size = group.length.to_f
      unless size == 0
        score = 0.0
        classes.each do |class_val|
          p = 0.0
          count = 0.0
          group.each do |row|
            if row[-1] == class_val
              count += 1
            end
          end
          p = count / size
          score_value = p * p
          score = score_value
        end
        gini += (1.0 - score) * (size / n_instances)
      end
    end
    gini
  end

  def to_terminal(group)
    outcomes = []
    group.each do |row|
      row_clone = row.clone
      outcomes << row_clone[-1]
    end
    outcomes.uniq.max_by { |x| outcomes.count }
  end

  def split(node, max_depth, min_size, n_features, depth, rnd)
    node[:left], node[:right] = node[:groups]
    node.delete(:groups)
    if node[:left].empty? || node[:right].empty?
      node_arg = node[:left] + node[:right]
      terminal_value = to_terminal(node_arg)
      node[:left] = terminal_value
      node[:right] = terminal_value
      return
    end
    # check for max depth
    if depth >= max_depth
      node[:left] = to_terminal(node[:left])
      node[:right] = to_terminal(node[:right])
      return
    end
    # process left child
    if node[:left].length <= min_size
      node[:left] = to_terminal(node[:left])
    else
      node[:left] = get_split(node[:left], n_features, rnd)
      split(node[:left], max_depth, min_size, n_features, depth + 1, rnd)
    end
    # process right child
    if node[:right].length <= min_size
      node[:right] = to_terminal(node[:right])
    else
      node[:right] = get_split(node[:right], n_features, rnd)
      split(node[:right], max_depth, min_size, n_features, depth + 1, rnd)
    end
    node
  end

  def build_tree(train, max_depth, min_size, n_features, rnd)
    root = get_split(train, n_features, rnd)
    split(root, max_depth, min_size, n_features, 1, rnd)
  end

  def predict(node, row)
    if row[node[:index]] < node[:value]
      if node[:left].class == Hash
        predict(node[:left], row)
      else
        node[:left]
      end
    else
      if node[:right].class == Hash
        predict(node[:right], row)
      else
        node[:right]
      end
    end
  end
end