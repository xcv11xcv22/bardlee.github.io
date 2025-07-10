---
tags:
  - Numpy
title: Numpy常見排序Library與應用
created: 2025-07-09T12:00:00
modified: 2025-07-09T12:00:00
---


# 1. np.argsort
- `np.argsort(scores)`：傳回的是分數排序後的原始索引（預設是升冪）
- `[::-1]`：反轉 array → 降冪排序
- 利用 `names[indices]` 可以對 array 根據 index 重排

```python
import numpy as np

names = np.array(['Alice', 'Bob', 'Charlie', 'David', 'Eva'])
scores = np.array([85, 92, 88, 76, 90])

# 取得分數排序（從大到小）的 index
sorted_indices = np.argsort(scores)[::-1]

# 取前三名
top3_indices = sorted_indices[:3]

# 對應姓名
top3_names = names[top3_indices]
top3_scores = scores[top3_indices]

print(top3_names)
print(top3_scores)

# 輸出
['Bob' 'Eva' 'Charlie']
[92 90 88]

```

# 2. np.sort

## 排序多維陣列的每一列

- `np.sort(arr, axis=1)`：對每一 row 做升冪排序
- `axis=0` 則會針對每一「欄」做排序（column-wise）
- `[:, ::-1]`：反轉每列順序，從升冪變降冪

```python
import numpy as np

arr = np.array([[3, 1, 2],
                [9, 7, 5],
                [6, 8, 4]])

sorted_arr = np.sort(arr, axis=1)
print(sorted_arr)

```

# 3. np.lexsort

用來**多欄位排序**（lexicographical sort，字典序排序）的方法

```python
import numpy as np

# 先依「班級」排序，再依「成績」排序
classes = np.array([1, 2, 1, 2, 1])
scores  = np.array([60, 80, 90, 60, 70])
idx = np.lexsort((scores, classes))
print(idx)
print(classes[idx])
print(scores[idx])


```

- `np.lexsort((次要, 主要))`  
    — 右邊最後一個是「最主要的排序依據」。
- 回傳排序後的 index，**可用於重排原本的陣列**。
- -**np.lexsort 永遠是升序。**
- **要降序→對 key 做處理 給Key負值即可。**

# 4. np.argmax

取得指定維度最大索引

```python

max_index = np.argmax(arr, axis=1)
print(max_index)

```

# 5. np.max

取得指定維度最大值

```python

max_value = np.max(arr, axis=1)
print(max_value)
```


# 按條件排序應用

```python
import numpy as np
names = np.array(['Ann', 'Ben', 'Cathy', 'David', 'Eve'])
scores = np.array([95, 55, 80, 45, 70])

pass_mask = scores >= 60
# 只對通過的分數排序
sorted_indices = np.argsort(scores[pass_mask])
# 原始及格的 index
pass_indices = np.where(pass_mask)[0]
# 新順序
new_order = pass_indices[sorted_indices]

# 建立新 array：不及格的留在原位
sorted_scores = scores.copy()
sorted_names = names.copy()
sorted_scores[pass_mask] = scores[new_order]
sorted_names[pass_mask] = names[new_order]

print(sorted_names)
print(sorted_scores)
```

- **np.where 的輸出為tupple**

# 維度的Mask重點

## 一維

```python

import numpy as np
arr = np.array([5, 7, 2, 8])
mask = arr > 5

print(np.where(mask))    # 輸出: (array([1, 3]),)

```



## 二維

```python


arr = np.array([[1, 2], [3, 4]])
mask = arr > 2
idx_tuple = np.where(mask)
print(idx_tuple)       # (array([1, 1]), array([0, 1]))
```

- 這裡 `[1, 1]` 是 row index，`[0, 1]` 是 column index