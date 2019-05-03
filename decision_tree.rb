class DecisionTree

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

  def get_split(dataset)
    dataset_rows = []
    dataset.each do |row|
      dataset_rows.append(row[-1])
    end
    class_values = dataset_rows.uniq
    b_index, b_value, b_score, b_groups = 999, 999, 999, nil
    for index in (0...dataset[0].length - 1)
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
      outcomes.append(row[-1])
    end
    outcomes.max
  end

  def split(node, max_depth, min_size, depth)
    left, right = node[:groups]
    node.delete(:groups)
    if not(left) || not(right)
      node[:left] = node[:right] = to_terminal(left + right)
      return
    end
    # check for max depth
    if depth >= max_depth
      node[:left], node[:right] = to_terminal(left), to_terminal(right)
      return
    end
    # process left child
    if left.length <= min_size
      node[:left] = to_terminal(left)
    else
      node[:left] = get_split(left)
      split(node[:left], max_depth, min_size, depth+1)
    end
    # process right child
    if right.length <= min_size
      node[:right]
      node[:right] = to_terminal(right)
    else
      node[:right] = get_split(right)
      split(node[:right], max_depth, min_size, depth+1)
    end
    node
  end

  def build_tree(train, max_depth, min_size)
    root = get_split(train)
    split(root, max_depth, min_size, 1)
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