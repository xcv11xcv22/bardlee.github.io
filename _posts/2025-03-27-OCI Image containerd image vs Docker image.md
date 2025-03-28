---
tags:
  - containerd
title: OCI Image containerd image vs Docker image
created: 2025-03-27T12:00:00
modified: 2025-03-27T12:00:00
---

當 Kubernetes 使用 `containerd` 來拉取映像時：

- `containerd` 會把映像儲存在 **自己的存儲庫**（`/var/lib/containerd`），而非 Docker 的 `/var/lib/docker`。
    
- 因此 `docker images` **無法看到** `containerd` 的映像，而 `containerd` 也**無法直接使用 Docker 的映像**。
    



### **如何管理 `containerd` 的映像**


如果你的 Kubernetes 節點是使用 `containerd`，則應該改用 `crictl` 或 `nerdctl` 來管理映像，而不是 `docker`。

crictl需要安裝，非內建指令
```bash
# 先去確認官方版本 https://github.com/containerd/nerdctl/releases
VERSION=2.0.4

curl -LO https://github.com/containerd/nerdctl/releases/download/v${VERSION}/nerdctl-${VERSION}-linux-amd64.tar.gz

#解壓縮
sudo tar -C /usr/local/bin -xzf nerdctl-${VERSION}-linux-amd64.tar.gz

nerdctl --version

# 輸出 nerdctl version 2.0.4

```


列出 containerd 中的映像
```bash
crictl images
```

或
```bash
nerdctl images
```

手動拉取映像
```bash
nerdctl pull nginx:latest
```


這與 docker pull nginx:latest 類似，但會拉取映像到 containerd。
手動刪除映像


```bash
crictl rmi nginx:latest
```
或


```bash
nerdctl rmi nginx:latest
```
使用 ctr（不推薦）

ctr 是 containerd 的官方 CLI，但較為底層，一般開發者較少使用：

```bash
ctr -n k8s.io images list
```
## **但`crictl` 不能 build image**


- `crictl` 是設計來跟 Kubernetes 使用的 **CRI (Container Runtime Interface)** API 通訊的工具，重點在於 **管理容器與映像**，而不是建構映像。
    
- **建構映像（build image）屬於 image builder 的範疇**，而 CRI 是沒有提供 build API 的。
    
- 所以 `crictl` 沒有 `build` 這種指令。

## [`nerdctl`](https://github.com/containerd/nerdctl)
`nerdctl`是 `containerd` 的 CLI，語法幾乎與 `docker` 相同，適合習慣使用 Docker 的開發者

#### 安裝 nerdctl

```bash
curl -sSL https://github.com/containerd/nerdctl/releases/latest/download/nerdctl-full-$(uname -m).tar.gz | tar -xz -C /usr/local/bin
```
或使用 apt install nerdctl（如果是 Ubuntu/Debian）

#### 使用 nerdctl 建立映像


```bash
nerdctl build -t my-image:latest .
```
這與 docker build -t my-image:latest . 相同

### 如何讓 containerd 使用 Docker 的映像

如果你有已經在 Docker 裡的映像，但 Kubernetes 是用 containerd，你可以：

    把 Docker 映像匯出為 tar 檔
```bash
docker save -o my-image.tar my-image:latest
```


將映像匯入 containerd
```bash
ctr -n k8s.io images import my-image.tar
```


確認映像已被 containerd 接受

```bash
crictl images
```


## **總結**

✅ **Kubernetes 1.20 之後不再需要 Docker，直接使用 `containerd` 或 `CRI-O`**  
✅ **`containerd` 的映像與 Docker 的映像不共用，它們存儲在不同位置**  
✅ **管理 `containerd` 映像應該使用 `crictl` 或 `nerdctl`，而不是 `docker`**  
✅ **可以用 `docker save` & `ctr images import` 把 Docker 映像轉移到 `containerd`**

👉 結論是，**當你使用 Kubernetes 時，基本上不需要再使用 Docker 了！** 🚀