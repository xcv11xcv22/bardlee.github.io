---
tags:
  - [Pandas]
title: Pandas常見排序Library與應用
created: 2025-07-09T12:00:00
modified: 2025-07-09T12:00:00
---


# 1.  sort_values

## 根據某一欄排序 DataFrame

```python
import pandas as pd

df = pd.DataFrame({
    'name': ['Amy', 'Ben', 'Cindy'],
    'score': [85, 92, 78]
})

df.sort_values(by='score', ascending=False)

```

## 根據多個欄位排序 DataFrame

```python
import pandas as pd

df = pd.DataFrame({
    'class': ['A', 'B', 'A', 'B'],
    'score': [88, 75, 95, 75]
})

df.sort_values(by=['class', 'score'], ascending=[True, False])

```

## 將最大值移到最上面

```python
import pandas as pd

df = pd.DataFrame({
    'class': ['A', 'B', 'A', 'B'],
    'score': [88, 75, 95, 75]
})

df.sort_values(by='score', ascending=False).head(1)
```

# 2. sort_index



# 3.  sort_index 和 sort_values差異

- `sort_values()` → 根據某一欄或多欄數值排序
- `sort_index()` → 根據 **索引順序** 排序


# 4. groupby
根據某欄位的值  分組並彙總, 可以使用聚合函數等等
```python
import pandas as pd

df = pd.DataFrame({
    'class': ['A', 'B', 'A', 'B'],
    'score': [88, 75, 95, 75]
})

df.sort_values(by='score', ascending=False).head(1)
```

# 5. 群組的平均值與總體平均的比較

```python
import pandas as pd

# 原始資料
df = pd.DataFrame({
    'name': ['Alice', 'Alice', 'Alice', 'Bob', 'Bob', 'Bob', 'Charlie', 'Charlie', 'Charlie'],
    'subject': ['Math', 'English', 'Science'] * 3,
    'score': [85, 90, 78, 88, 76, 92, 90, 85, 80]
})

# 1️⃣ 每位學生的平均分數
student_avg = df.groupby('name')['score'].mean()
print("=== 每位學生平均分數 ===")
print(student_avg)
print()

# 2️⃣ 全班總平均（不分人、不分科目）
overall_avg = df['score'].mean()
print("=== 全班總平均 ===")
print(overall_avg)
print()

# 3️⃣ 平均分數高於全班總平均的學生
above_avg_students = student_avg[student_avg > overall_avg]
print("=== 平均高於全班總平均的學生 ===")
print(above_avg_students)

```

輸出
```yaml
=== 每位學生平均分數 ===
name
Alice      84.333333
Bob        85.333333
Charlie    85.000000
Name: score, dtype: float64

=== 全班總平均 ===
85.55555555555556

=== 平均高於全班總平均的學生 ===
Series([], Name: score, dtype: float64)

```

#  Map vs Join vs Merge
##  三種方式的對應邏輯比較

|方法|key 怎麼決定？|是否可自訂 key 欄位？|適合使用時機|
|---|---|---|---|
|`map()`|使用 **Series 的 index** 當作 key| 不可指定，用的是 index|單欄位對應（像 vlookup）|
|`join()`|使用 **DataFrame 的 index** 對應| 可用 `on=` 參數（若 index 不一樣）|以 index 合併資料表|
|`merge()`|使用你指定的欄位 `on="..."` 作為 key|明確指定 key|欄位對欄位合併（如 SQL join）|

```python
bonus_map = df_bonus.set_index("name")["bonus"]
df["bonus"] = df["name"].map(bonus_map)


df1 = df.set_index("name")
df2 = df_bonus.set_index("name")
df_joined = df1.join(df2, how="left").reset_index()

df_merged = pd.merge(df, df_bonus, on="name", how="left")

```


# 排序後的注意事項

### 1. 排序後 index 會亂掉

```python
df = pd.DataFrame({
    'name': ['Amy', 'Ben', 'Cindy'],
    'score': [85, 92, 78]
})

df_sorted = df.sort_values(by='score', ascending=False)
print(df_sorted)

#輸出

   name  score
1   Ben     92
0   Amy     85
2 Cindy     78

#修正
df_sorted.reset_index(drop=True, inplace=True)

```

drop=True 的意義
若為False會多一個Index欄位

```python

   index   name  score
0      1   Ben     92
1      0   Amy     85
2      2 Cindy     78

```

inplace=True 的意義
代表**直接修改原始變數**，不會回傳新的 DataFrame。

```python

#否則要這樣寫
df_sorted = df_sorted.reset_index(drop=True)

```
