---
tags:
  - containerd
title: containerd 只要有nvidia-container-runtime就能執行 GPU 容器?
created: 2025-03-25T17:00:00
modified: 2025-03-25T17:00:00
---
111
當ctr 要執行 gpu 驗證時的注意事項

這是一個非常關鍵的問題，簡單來說：

```text
❌ 不完全是。只有安裝 nvidia-container-runtime 還不夠，還需要正確整合到 containerd 的設定中，才能讓 containerd 實際「使用」這個 runtime 來執行 GPU 容器。
```

## ✅ 必要條件（以 containerd 為例）：

| 條件                                                     | 是否必需 | 說明                                                       |
| ------------------------------------------------------ | ---- | -------------------------------------------------------- |
| ✅安裝 `nvidia-container-runtime`                        | 是    | 提供能夠在容器內掛載 GPU 驅動與設備的功能                                  |
| ✅ 安裝 `nvidia-container-toolkit`                        | 是    | 負責產生與 runtime 整合所需的設定檔，例如 runtime hook                   |
| ✅ `containerd` 設定啟用 `nvidia` runtime handler           | 是    | 編輯 `/etc/containerd/config.toml`，註冊名為 `nvidia` 的 handler |
| ✅ containerd 重啟                                        | 是    | 設定變更後必須重新啟動才能生效                                          |
| ✅ 正確使用 `--gpus` 或 `runtimeClassName` 呼叫 nvidia runtime | 是    | 否則 containerd 預設還是用 runc，無法掛載 GPU                        |


🧪 例子：正確執行 GPU 容器（使用 containerd）  
以我的fedora 41 來說已經預設有 containerd  
記得docker.io/nvidia/cuda:12.3.0-baseu必須先pull
```bash
sudo ctr run --rm --gpus 0 docker.io/nvidia/cuda:12.3.0-base nvc nvidia-smi
```


如果你只裝了 nvidia-container-runtime，但：

    沒安裝 toolkit

    沒設定 config.toml  

    沒重啟 containerd 

這條指令就會失敗，出現錯誤如：
```bash
OCI runtime create failed: ... unknown runtime
```


📦 安裝與設定範例（Fedora）
1. 安裝：
```bash
sudo dnf install -y nvidia-container-toolkit
```


這同時會安裝 nvidia-container-runtime。
2. 產生 containerd 設定（自動加到 config.toml）：
```bash
sudo nvidia-ctk runtime configure --runtime=containerd
```


這是 NVIDIA 提供的官方工具，用來安全地加設定。
1. 重啟 containerd


```bash
sudo systemctl restart containerd
```
✅ 總結：你需要這三樣缺一不可：

```bash
nvidia-container-runtime

nvidia-container-toolkit

containerd.config.toml #註冊 nvidia handler 並重啟

```
  
只有裝 runtime，但不整合，不會自動生效。