---
tags: [leetcode]
title: 27.Remove Element
created: '2023-05-24T11:06:18.241Z'
modified: '2023-05-24T22:37:16.598Z'
---

# 27.Remove Element

給你一個數組 nums 和一個值 val，你需要 原地 移除所有數值等於 val 的元素，並返回移除後數組的新長度。

不要使用額外的數組空間，你必須僅使用 O(1) 額外空間並 原地 修改輸入數組。

元素的順序可以改變。你不需要考慮數組中超出新長度後面的元素。

意思你要在本地修改陣列，nums剩下size與本來的長度不一樣不重要了，直接回傳新的長度

# Example

Input: nums = [0,1,2,2,3,0,4,2], val = 2  
Output: 5, nums = [0,1,4,0,3,_,_,_]

# 思考

想確認陣列的每個數字，一定要一個完整的for loop  
這個是指針i

還要得到新的的陣列長度  
這個是指針k  
根據題意，k增加的條件是找出非val的數值  
nums[i] != val  
如果是true，nums[k++] = nums[i]


# 程式

```java
public int removeElement(int[] nums, int val) {
  int k = 0;
  for (int i = 0; i < nums.length; i++) {
      if(nums[i] != val){
          nums[k++] = nums[i];
      }
  }
  return k;
}
```
