---
tags:
  - 作品
title: AI聊天室專案-EchoMind介紹
created: 2025-10-15T12:00:00
modified: 2025-10-15T12:00:00
---

## <a href="https://chat.bardcloud.online" target="_blank">AI聊天室專案-EchoMind連結</a>


這是一個從零開發的全端即時聊天室，支援多人互動、私聊與 AI 對話。  
系統整合 **微調後的本地 LLM**、**RAG 知識檢索**、**RabbitMQ 串流回覆**、**Redis 對話記憶**、  
以及 **自訓練 GAN 生成頭像模型**，實現智慧化且可擴充的對話體驗。

---

## 主要功能

- **即時群聊／私訊**：以 WebSocket（STOMP over SockJS）實現雙向即時通訊。
    
- **串流回覆 (Streaming)**：AI 回覆逐字顯示，透過 **RabbitMQ** 分段傳輸與整併，提升互動即時性。
    
- **RAG 回覆 (Retrieval-Augmented Generation)**：  
    採用 **BGE-M3 向量嵌入模型** 與 **VCPG 向量資料庫**，搭配 **Chunk 分段與重排序** 提升語意檢索品質。
	目前 RAG 模組主要使用 **iPhone 17 相關問題資料集** 進行語意擴充與知識檢索測試。
- **LLM 微調 (Fine-tuning)**：  
    以 **LoRA** 技術微調本地大型語言模型，使其更熟悉 **亞洲、台灣與三國人物** 等內容領域，  

- **四房間 × 四種風格大頭貼**：  
    每個聊天室房間綁定一種風格（極簡／漫畫／像素／寫實），由 **自行訓練的 GAN 模型** 生成。
- **指令畫圖：  
    「畫柴犬」會在聊天室回傳 **832×384** 生成柴犬圖片。
- **AI 畫圖互動**：  
    當使用者輸入「畫柴犬」時，系統以 **高解析 GAN 模型（832×384）** 生成柴犬圖片。
    
- **上下文記憶**：使用 **Redis** 保存對話脈絡，使 AI 能連貫理解多輪對話。
    
- **響應式 UI**：前端採 **React + Chakra UI**。
    

---

## 技術架構

- **Frontend**：React、Chakra UI、STOMP over WebSocket
    
- **Backend**：Spring Boot (Java 17)、RabbitMQ、REST API
    
- **AI Service**：FastAPI (Python)、**本地 LLM（LoRA 微調）**
    
- **Embedding / RAG**：**BAAI/bge-m3 嵌入**、**VCPG 向量索引**、Chunk + Rerank
    
- **ONNX 影像推論**：
    
    - 共 5 個模型：**4 個 GAN 頭像模型 + 1 個高解析柴犬生成模型**
        
    - 使用 **ONNX Runtime（CPU Execution Provider）** 進行 CPU 推論
        
- **Storage**：PostgreSQL、Redis
    
- **Deploy**：Kubernetes（Minikube + containerd）、Cloudflare Tunnel
    

---

##  本地部署環境

系統運行於本人的 **Fedora Linux 工作站**：

- **NVIDIA GeForce RTX 5060 Ti (16 GB VRAM)**
    
- **CUDA 12.x / PyTorch 2.8**  
    採用 **Minikube + containerd** 管理多容器服務，  
    整合 Spring Boot 後端、FastAPI AI 服務、PostgreSQL、Redis、RabbitMQ 與本地 LLM 推論容器。  
    外部訪問透過 **Cloudflare Tunnel** 提供安全連線。
    

---

##  模型掛載與持久化

- 使用 **Kubernetes PersistentVolume (PV)** 與 **PersistentVolumeClaim (PVC)** 掛載本地模型資料夾，  
    指向 Hugging Face 快取路徑 和Lora路徑
- 採用 `hostPath` 與 `storageClassName: manual` 靜態綁定，確保容器重啟後模型可直接使用，  無需重新下載權重，實現本地高效推論。

---

## 模型訓練與技術挑戰

- 所有頭像與柴犬生成模型皆由本人以 **生成式對抗網路（GAN）** 自行訓練完成。
    
- 採用 **WGAN-GP（含 Gradient Penalty）** 架構，並結合 **EMA (Exponential Moving Average)** 穩定生成品質。
    
- 使用 **DiffAug** 資料增強與多階段訓練策略：  
    先訓練 278×128 低解析模型，再慢慢升級至 832×384 高解析度以強化細節。
    
- 透過 **梯度累積（Gradient Accumulation）** 與顯存優化策略（控制 batch size、釋放計算圖），  
    在單張 GPU 上完成高解析訓練。
    
- 訓練完成後，以 `torch.onnx.export()` 導出生成器為 **ONNX 模型**，整合至 Spring Boot 作 CPU 推論。
    

---

## 開發重點與特色

- 實作 **RabbitMQ 串流回覆管線**（token 切片 → 併發傳遞 → 前端逐字渲染）。
    
- 建立 **RAG 模組**（BGE-M3 嵌入、Chunk/Overlap、VCPG 索引與 rerank）。
    
- **微調本地 LLM（LoRA）**，強化專域問答與系統指令對齊。
- 整合 **5 組自訓練的 ONNX GAN 模型** 至 Spring Boot，讓 Java 服務可直接以 **CPU 進行影像生成推論**，實現跨平台部署與低資源環境相容性

- 以 **Redis** 實現長對話記憶機制，支援多輪上下文理解。
    
- 完成本地 **Kubernetes 容器化** 與對外部署流程（含 PV/PVC 靜態綁定與模型持久化配置）。

##  使用教學

**要使用ai功能需選擇Ai為說話對象**
### 手機版

<img src="https://i.ibb.co/4ZsTDqBJ/Screenshot-20251016-074031-Firefox.jpg" alt="Screenshot-20251016-074031-Firefox" border="0">

<img src="https://i.ibb.co/ZpkL0nVM/Screenshot-20251016-074059-Firefox.jpg" alt="Screenshot-20251016-074059-Firefox" border="0">

<img src="https://i.ibb.co/C3KWn8GK/Screenshot-20251016-074136-Firefox.jpg" alt="Screenshot-20251016-074136-Firefox" border="0">

### 電腦版

<a href="https://ibb.co/cn0yLyt"><img src="https://i.ibb.co/SCb6r60/1.png" alt="1" border="0"></a>

<a href="https://ibb.co/PGSX4WJv"><img src="https://i.ibb.co/b5fwLvYM/2.png" alt="2" border="0"></a>



#### 畫柴犬教學
1. 輸入「畫柴犬」至輸入框後送出

<a href="https://ibb.co/d02b4DkX"><img src="https://i.ibb.co/XZsyxtF6/draw1.png" alt="draw1" border="0"></a>

2. 可點擊圖放大檢視

<a href="https://ibb.co/tTGPn86x"><img src="https://i.ibb.co/G463GcDt/draw2.png" alt="draw2" border="0"></a>

3. 位於圖片右上角的X可關閉圖片

<a href="https://ibb.co/Xfb0gfYm"><img src="https://i.ibb.co/4w7vGw1B/draw3.png" alt="draw3" border="0"></a>


## Demo

### Streaming回覆

<a href="https://ibb.co/sp4W99HF"><img src="https://i.ibb.co/20rZ33Nj/2025-10-1609-15-10-ezgif-com-video-to-gif-converter.gif" alt="2025-10-1609-15-10-ezgif-com-video-to-gif-converter" border="0"></a>


### Onnx柴犬成像圖片


![柴犬1](https://i.ibb.co/RkwbsTMT/ec842543-fe34-40d3-94c1-3d2fa00920a1.jpg)
![柴犬2](https://i.ibb.co/5hVTx6nM/64daf1fb-d6d5-4e14-83c9-7a247cba07e2.jpg)


### 上下文記憶

<a href="https://ibb.co/gbpwxZ1s"><img src="https://i.ibb.co/mrwt35sQ/1760571024711.jpg" alt="1760571024711" border="0"></a>



### IPhone17 rag回覆

<a href="https://ibb.co/Hffp6cQ9"><img src="https://i.ibb.co/jPPZmCFj/iphone1.png" alt="iphone1" border="0"></a>






