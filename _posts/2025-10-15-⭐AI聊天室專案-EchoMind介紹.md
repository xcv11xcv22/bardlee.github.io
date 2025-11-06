---
tags:
  - 作品
title: ⭐AI聊天室專案-EchoMind介紹
created: 2025-10-15T12:00:00
modified: 2025-10-15T12:00:00
---

## EchoMind：我獨立打造的 AI 實驗聊天室，想為聊天重新點火

你還記得「聊天室」最熱鬧的時代嗎？  
曾經的它，是交朋友、聊天、分享生活最溫暖的地方。如今，它幾乎被演算法社群取代。

我一直在想：  
**如果把最新的 AI 技術放進聊天室，會不會重新變得好玩？**

帶著這個念頭，我用半年時間，一個人從零打造了 **EchoMind** ——  
一個能和 AI 一起聊天、一起探索、一起創造的實驗性聊天室。

---

## 為什麼做 EchoMind？

我想用 AI，為快消失的聊天室文化點一把新火

大多數 AI 都停留在一問一答、工具性、缺乏人味。  
而聊天室，曾經是最有溫度的互動場域。

我開始想像：

🤖 如果 AI 是聊天室中的一個角色，而不是客服？  
🔥 如果讓人類與 AI 一起聊天，而不是輪流輸入？  
🎭 如果進聊天室就能擁有 AI 為你生成的獨特身份？

我想用 AI 重新賦予「聊天」新的形式。  
EchoMind 就是這個念頭的實驗。

---

## 我如何讓 AI「像在聊天」


我想讓 EchoMind 的 AI 更像一個會聊天的角色，因此做了三件事：

- **Token 串流回覆（WebSocket）**  
    AI 不是等想完才回，而是像人在打字，一句一句出來，節奏更自然
    
- **Redis 短期記憶（依使用者）**  
    AI 會記住最近聊過的內容，不會每句都像第一次見面
    
- **RAG（Postgres + pgvector + BGE-M3）**  
    用向量搜尋補強知識，不只陪聊，也能講得準、有內容

- **   Fine tune  **  
	    學習專門的知識如三國, 亞洲, 台灣等等
	

這 3 件事的目標很簡單：  
**AI 不只是回你，而是能接你話、記得你、講得更貼近你。**

---

## 技術架構亮點

EchoMind 的架構不是堆技術，而是為了能長大。

- **前端：React + WebSocket**  
    多人聊天室、即時互動、AI 串流都在這層體現
    
- **後端：Spring Boot**  
    管理房間、消息轉發、使用者狀態，並直接在 Java 生態執行 **ONNX Runtime**  
    GAN 生圖放這層，是為了更順的進場體驗與更低延遲，並使用cpu推論onnx
    
- **AI 層：FastAPI（LLM + RAG）**  
    與聊天服務解耦，模型可替換，可擴展不同 AI 角色
    

---

## 我為什麼用 ONNX 在 Spring Boot 做生成？

我把 **GAN 模型從 PyTorch 轉為 ONNX**，並在 Spring Boot 直接推理，而不是放 AI 層，原因有兩個：

- CPU推論我訓練的Gan速度非常快
- 讓「進入聊天室就拿到角色」這件事更即時、更順暢。

這是一個 **體驗優先 × 架構思考** 的取捨：

- 不用跨服務請求 → 延遲更低
    
- 角色生成與登入體驗緊密結合
    
- AI 層維持乾淨，專注對話與 RAG
    
---

### 部署與對外體驗：Cloudflare Pages × minikube × Cloudflare Tunnel

我希望 EchoMind 不只是「我自己能跑」，而是任何人都能直接體驗。  
因此我採用了前後端分離且具產品化思維的部署方式：

- **前端（React）**：部署於 **Cloudflare Pages**，由全球 CDN 加速提供 HTTPS 入口，同時具備 SEO 友善特性，讓使用者第一眼就像在使用正式產品
    
- **後端（Spring Boot + ONNX、生圖、FastAPI、Postgres、Redis、Rabbitmq）**：運行在本機 **minikube**，保持低成本、高掌控度
    
- **對外連線**：透過 **Cloudflare Tunnel** 將後端 API 安全公開成自有子網域 **api.bardcloud.online**，不需公網 IP，也不用自己處理 SSL
    

---

## 如果你願意，我希望你能親自進來玩玩

🔗 Demo 入口：<a href="https://chat.bardcloud.online" target="_blank">AI聊天室專案-EchoMind</a>


💻  GitHub：<a href="https://github.com/lipeijia/chat-room" target="_blank">前後端原碼</a>, <a href="https://github.com/xcv11xcv22/chat-room-bot" target="_blank">AI層原碼</a>

如果你想聊聊這個專案、AI、產品開發，或你覺得我們可以激出什麼火花，歡迎找我。
    
---

##   使用教學

**要使用ai功能需選擇Ai為說話對象**
### 手機版

<img src="https://img.bardcloud.online/ai_project/Screenshot-20251016-074031-Firefox.jpg" alt="Screenshot-20251016-074031-Firefox" border="0">

<img src="https://img.bardcloud.online/ai_project/Screenshot-20251016-074059-Firefox.jpg" alt="Screenshot-20251016-074059-Firefox" border="0">

<img src="https://img.bardcloud.online/ai_project/Screenshot-20251016-074136-Firefox.jpg" alt="Screenshot-20251016-074136-Firefox" border="0">

### 電腦版

<a href="https://img.bardcloud.online/ai_project/1.png"><img src="https://img.bardcloud.online/ai_project/1.png" alt="1" border="0"></a>

<a href="https://img.bardcloud.online/ai_project/2.png"><img src="https://img.bardcloud.online/ai_project/2.png" alt="2" border="0"></a>

#### 畫柴犬教學

1.輸入「畫柴犬」至輸入框後送出


<a href="https://img.bardcloud.online/ai_project/draw1.png"><img src="https://img.bardcloud.online/ai_project/draw1.png" alt="draw1" border="0"></a>


2.可點擊圖放大檢視


<a href="https://img.bardcloud.online/ai_project/draw2.png"><img src="https://img.bardcloud.online/ai_project/draw2.png" alt="draw2" border="0"></a>


3.位於圖片右上角的X可關閉圖片


<a href="https://img.bardcloud.online/ai_project/draw3.png"><img src="https://img.bardcloud.online/ai_project/draw3.png" alt="draw3" border="0"
height="927"
  loading="lazy"
  decoding="async"
  fetchpriority="low"></a>


## 👍Demo

### Streaming回覆

<a href="https://img.bardcloud.online/ai_project/streaming.gif"><img src="https://img.bardcloud.online/ai_project/streaming.gif" alt="streaming.gif" border="0"></a>

### Onnx柴犬成像圖片

![柴犬1](https://img.bardcloud.online/ai_project/dog1.jpg){:loading="lazy" decoding="async" height="832"}


![柴犬2](https://img.bardcloud.online/ai_project/dog2.png){:loading="lazy" decoding="async" height="832"}


### 上下文記憶

<a href="https://img.bardcloud.online/ai_project/memory.png?n=1"><img src="https://img.bardcloud.online/ai_project/memory.png?n=1" alt="上下文記憶" border="0" height="952"
  loading="lazy"
  decoding="async"
  fetchpriority="low"></a>

### IPhone17 rag回覆

<a href="https://img.bardcloud.online/ai_project/iphone1.png"><img src="https://img.bardcloud.online/ai_project/iphone1.png" alt="iphone1" border="0"></a>




