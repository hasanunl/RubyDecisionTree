require 'sciruby'

class DecisionTree
  def test_split(index, value, dataset)
    left, right = Array.new, Array.new
    for row in dataset
      if row[index] < value
        left.append(row)
      else
        right.append(row)
      end
    end
    return left, right
  end

  def get_split(dataset)
    dataset_rows = Array.new
    dataset.each do |row|
      dataset_rows.append(row[-1])
    end
    class_values = dataset_rows.uniq
    pp dataset[0].length - 1
    b_index, b_value, b_score, b_groups = 999, 999, 999, nil
    for index in (0..dataset[0].length - 1)
      dataset.each do |row|
        groups = test_split(index, row[index], dataset)
        gini = gini_index(groups, class_values)
        if gini < b_score
          b_index, b_value, b_score, b_groups = index, row[index], gini, groups
        end
      end
    end
    return {index: b_index, value: b_value, groups: b_groups}
  end

  def gini_index(groups, classes)
    n_instances = 0.0
    groups.each do |group|
      n_instances += group.size
    end
    gini = 0.0
    groups.each do |group|
      size = group.size
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
          score += p * p
        end
        gini += (1.0 - score) * (size / n_instances)
      end
    end
    return gini
  end

  def to_terminal(group)
    outcomes = Array.new
    group.each do |row|
      outcomes.append(row[-1])
    end
    return outcomes.max
  end

  def split(node, max_depth, min_size, depth)
    left, right = node[:groups]
    # check for a no split
    if not left or not right
      node[:left] = node[:right] = to_terminal(left + right)
      return
    end
    # check for max depth
    if depth >= max_depth
      node[:left], node[:right] = to_terminal(left), to_terminal(right)
      return
    end
    # process left child
    if len(left) <= min_size
      node[:left] = to_terminal(left)
    else
      node[:left] = get_split(left)
      split(node[:left], max_depth, min_size, depth+1)
    end
    # process right child
    if len(right) <= min_size
      node[:right] = to_terminal(right)
    else
      node[:right] = get_split(right)
      split(node[:right], max_depth, min_size, depth+1)
    end
  end

  def build_tree(train, max_depth, min_size)
    root = get_split(train)
    split(root, max_depth, min_size, 1)
    return root
  end
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
pp tree
# gi_2 = gini_index([[[1, 0], [1, 0]], [[1, 1], [1, 1]]], [0, 1])
# pp gi_2


