---
tags:
  - pytorch
title: multiprocessing vs pytorch
created: 2025-03-26T16:00:00
modified: 2025-03-26T16:00:00
---


在 PyTorch 中進行模型訓練或推論時，**GPU 使用率已經很高，甚至 CPU 也偏高**，這是因為 **PyTorch 背後已經內建了高度優化的並行處理機制**，包括：

- **GPU 計算：使用 CUDA 進行矩陣運算（TensorCore、cuDNN、cuBLAS 等）**
    
- **CPU 資源：用於資料加載、前後處理、梯度運算等**
    
- **資料加載（DataLoader）：可內建使用多進程 `multiprocessing` 加速 I/O**


## ✅ PyTorch 本身是否需要手動使用 `multiprocessing`？

在大多數情況下，**不需要自己寫 `multiprocessing.Process()` 來跑 PyTorch**，因為：

- PyTorch 本身的資料加載、模型訓練就已經支援並行
    
- 使用 `torch.utils.data.DataLoader` 時，可以直接透過 `num_workers` 來自動開多個子進程進行資料加載
    
- 多 GPU 訓練時，推薦使用內建的分散式訓練 API，如 `torch.nn.DataParallel` 或 `torch.distributed`
---



> #### num_workers > 0 時，背景自動啟動multiprocessing

## 使用 PyTorch 搭配 `multiprocessing` 時的注意事項

|問題|建議|
|---|---|
|CUDA 初始化會在 fork 後失敗|避免在 `multiprocessing` 中 fork 後才使用 CUDA|
|多 GPU 模型訓練|建議使用 `torch.distributed` 而非手動 `multiprocessing`|
|CUDA Tensor 在多進程中傳遞|**不要在進程間傳遞 CUDA Tensor**，容易出錯，請在每個進程內獨立建立 GPU 張量|
|多進程資料加載死鎖|確保程式在 `__main__` 下執行，且 `DataLoader` 的 `num_workers` 不要設過高|

---

## ✅ 結論與建議

| 需求                      | 建議                                                        |
| ----------------------- | --------------------------------------------------------- |
| **單 GPU 訓練 / 推論**，想提升效能 | ✅ 使用 `DataLoader(num_workers > 0)`                        |
| **多 GPU 並行任務（非同步訓練）**   | ✅ 自行用 `multiprocessing.Process` 分別跑                       |
| **多 GPU 訓練同一模型**        | ✅ 使用 `torch.nn.DataParallel` 或 `torch.distributed.launch` |
| **CPU 利用率過高**           | ✅ 檢查 `num_workers`、`pin_memory` 設定，或考慮資料前處理是否過重           |
| **GPU 使用率已滿但速度仍慢**      | ✅ 檢查資料載入瓶頸，可使用預讀（`prefetch_factor`）或 LMDB 儲存資料            |


## 額外說明

## 一、**「CUDA 初始化會在 fork 後失敗」是什麼意思？**

### 🔸背景

- 在 Linux（包含 Fedora）中，`multiprocessing` 的預設進程啟動方式是 **fork**。
    
- 「fork」會**複製父進程的記憶體狀態**（連同 CUDA 上的上下文），但 CUDA 並**不支援這種 fork 後的上下文繼承**。
    

### 🧨 結果會怎樣？

如果你在主進程中初始化了 CUDA（例如呼叫 `torch.cuda.is_available()`、建立 tensor）然後再用 `Process()` fork 子進程，**子進程中再使用 CUDA 時可能會報錯**。

### 🚫 錯誤示範：



# 主進程先初始化了 CUDA

```python
import torch
from multiprocessing import Process
torch.cuda.is_available()  # 初始化 CUDA

def worker():
    # 在子進程中使用 GPU
    x = torch.tensor([1.0]).cuda()  # 可能報錯！
    print(x)

if __name__ == '__main__':
    p = Process(target=worker)
    p.start()
    p.join()

❗常見錯誤：

RuntimeError: CUDA error: initialization error
```



✅ 正確做法：

👉 避免在 fork 子進程之前初始化 CUDA！
```python
import torch
from multiprocessing import Process

def worker():
    # 在子進程中再初始化 CUDA
    x = torch.tensor([1.0]).cuda()  # OK！
    print(x)

if __name__ == '__main__':
    p = Process(target=worker)
    p.start()
    p.join()
```


## 二、「不要在進程間傳遞 CUDA Tensor」是什麼意思？
🔸背景

    multiprocessing 的資料交換是透過 序列化（pickle） 傳遞物件。

    但 CUDA Tensor 不是普通的記憶體資料，它存在 GPU 的顯存中，Python 的序列化並不能處理它。

🧨 這樣會報錯或行為不正確：
```python
import torch
from multiprocessing import Process, Queue

def worker(q):
    t = q.get()         # 嘗試從 queue 中拿 CUDA Tensor
    print(t.cuda())     # 可能錯誤或行為不預期

if __name__ == '__main__':
    q = Queue()
    x = torch.tensor([1.0]).cuda()
    q.put(x)            # 嘗試傳 CUDA Tensor（不行❌）

    p = Process(target=worker, args=(q,))
    p.start()
    p.join()
```


✅ 正確做法：

你可以 只傳 CPU Tensor、numpy、int、float 等普通資料，再讓子進程自己搬上 GPU。

```python
import torch
from multiprocessing import Process, Queue

def worker(q):
    x_cpu = q.get()            # 拿到 CPU Tensor
    x_gpu = x_cpu.cuda()       # 在子進程自己搬上 GPU
    print(x_gpu)

if __name__ == '__main__':
    q = Queue()
    x = torch.tensor([1.0])    # CPU Tensor
    q.put(x)

    p = Process(target=worker, args=(q,))
    p.start()
    p.join()
```

|問題|錯誤|解法|
|---|---|---|
|fork 後 CUDA 初始化失敗|子進程用到 CUDA 時報錯|❗不要在主進程用到 CUDA，讓子進程自己初始化|
|多進程傳 CUDA Tensor|可能無法序列化 / 損壞|✅ 傳 CPU Tensor，子進程自己轉 `.cuda()`|

---
