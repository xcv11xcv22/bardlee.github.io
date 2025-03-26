---
tags:
  - k8s
title: gpu pod 持續Pending, 無法至running
created: 2025-03-26T:00:00
modified: 2025-03-26T16:00:00
---

當看到 Pod 卡在 Pending，其實是 排程器（Scheduler）發現沒有可用 GPU，所以無法排到任何 Node 上。根本原因還是：  


我碰到的例子是缺少libnvidia-ml.so.1

    NVIDIA Device Plugin DaemonSet 在它自己的容器內找不到 libnvidia-ml.so.1，因此沒註冊 GPU。

從日誌可見：
```shell
could not load NVML library: libnvidia-ml.so.1: cannot open shared object file
...
No devices found. Waiting indefinitely.
```


>只要 device plugin 「**找不到 GPU**」→ K8S 就不會有 nvidia.com/gpu 資源 → 要求  GPU 的 Pod 一律 Pending。
為什麼 Device Plugin Pod 找不到 libnvidia-ml.so.1？


>因為它 沒有用到 **nvidia runtime**，導致 GPU 驅動檔案沒有自動掛進去容器。
若執行 ctr run --rm --gpus 0 ... 之所以可以執行成功，是因為直接呼叫 containerd（或是 nvidia-container-runtime）跑容器  

>但是 device plugin 本身 是一個 DaemonSet，Kubernetes 排它時，預設只會用 runc。如果 device plugin 沒跑在 nvidia runtime 上，就不會看到 GPU 驅動庫。

# Nvidia device plugin的介紹
---

### 1. Device Plugin 只是一個 DaemonSet

    它的目的是掃描主機上的 GPU，並告訴 Kubernetes：「我這台機器有 GPU，可以用！」

    它不會自己執行需要 GPU 的程式，也不需要自己掛上 GPU device。

### 2. 它使用 hostPath 掛載 /dev/nvidia* 與驅動資料夾

    DaemonSet 通常會這樣寫：
```yaml
 volumeMounts:
    - name: dev
      mountPath: /dev
    volumes:
    - name: dev
      hostPath:
        path: /dev
```


### 解法 1：讓 Device Plugin DaemonSet 使用 runtimeClassName: nvidia

你可以直接 Patch 官方的 Device Plugin DaemonSet，讓它的容器 改用 nvidia runtime。
預設官方的 YAML 沒有指定 runtimeClass，於是它用預設 runc，就讀不到 libnvidia-ml.so.1。
1. 先套用原檔
```bash
kubectl apply -f https://raw.githubusercontent.com/NVIDIA/k8s-device-plugin/v0.14.1/nvidia-device-plugin.yml
```


2. Patch DaemonSet

把下面內容存成 patch-ds.yaml：
```yaml
spec:
  template:
    spec:
      runtimeClassName: nvidia
```


然後執行：
```bash
kubectl -n kube-system patch daemonset nvidia-device-plugin-daemonset 
  --patch "$(cat patch-ds.yaml)"

```

Patch 後再看一下 DaemonSet YAML，你會看到多了 runtimeClassName: nvidia：


```bash
kubectl -n kube-system get daemonset nvidia-device-plugin-daemonset -o yaml

```


這樣，Device Plugin 的容器就會以 nvidia runtime 執行，能掛載到 libnvidia-ml.so.1。
### 解法 2：將 nvidia 設為「容器預設 runtime」

如果你不想改 DaemonSet 的 runtimeClassName，也可以讓整個 containerd 預設就跑 nvidia runtime。
但這通常 **不建議**，因為這樣所有 Pod 都會帶 GPU runtime 啟動（不一定合適，也可能有額外開銷）。

做法是把 /etc/containerd/config.toml：
```toml
[plugins."io.containerd.grpc.v1.cri"]
  default_runtime_name = "runc"
  ...
```

改為

```toml
[plugins."io.containerd.grpc.v1.cri"]
  default_runtime_name = "nvidia"
  ...
```

```bash
#然後 
sudo systemctl restart containerd
```

不過這樣做完之後，所有 Pod 預設都會用 nvidia runtime。除非你整台機器都只跑 GPU workload，否則比較少人這樣做。
驗證：Device Plugin 會開始註冊 GPU

不管你用哪個解法，只要讓 Device Plugin 以 nvidia runtime 來跑，就會看到它 log 裡改為：
```bash
IXXXX main.go:XXX] Starting to serve on /var/lib/kubelet/device-plugins/nvidia.sock
IXXXX main.go:XXX] Registered GPU device ...
```


然後：
```bash
kubectl get nodes -o jsonpath='{.items[0].status.allocatable.nvidia\.com/gpu}'
# → 1  # 代表有偵測到gpu
```


最後你的 gpu-debug Pod或 gpu-test Pod就能正常排程執行，而不再卡在 Pending。
總結

    問題根源：Device Plugin DaemonSet 預設跑在 runc → 容器內沒看到 GPU 驅動 → 不註冊 nvidia.com/gpu

    解法：

        (建議) DaemonSet patch：加 runtimeClassName: nvidia

        (可選) 整台預設 runtime 改成 nvidia（風險較高）

    成功驗證：Pod 不再 Pending，kubectl get node 顯示有 GPU 資源