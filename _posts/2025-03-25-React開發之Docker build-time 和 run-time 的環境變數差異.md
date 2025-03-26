---
tags:
  - react
title: React開發之Docker build-time 和 run-time 的環境變數差異
created: 2025-03-25T16:00:00
modified: 2025-03-25T16:00:00
---
你**可以在啟動容器時再指定 `REACT_APP_ENV`**，但它**只對「執行階段」的應用有效**。

但因為 React 是 **在建置（build）時就把環境變數寫死到靜態檔案裡**的，你如果要讓 `REACT_APP_ENV` 真正影響 React 的行為，那**只能在 `npm run build` 時給定**這個變數。

---

### 🧠 更具體地說：

#### React 的特性：

React（使用 CRA 建立的）應用程式是前端靜態網站，它在 `npm run build` 時就已經把環境變數「寫死」進 `.js` 檔案裡了


### 💡 所以要根據情境選擇：

|目標|是否可用 run-time 指定環境變數？|說明|
|---|---|---|
|React App 不同環境行為（如 API base URL）|❌ 否|必須在 build 時指定 `REACT_APP_ENV`|
|Nginx 或後端應用的行為|✅ 可|可在 `docker run -e` 指定環境變數|

react dockerfile
```dockerfile
ARG REACT_APP_ENV=K8S

ENV REACT_APP_ENV=$REACT_APP_ENV
# 執行 React 應用建置

RUN npm run build
```
react  
config.js  
config.value.js  

```js
import _configValueSwitch from './config.value';

  

let NOW_ENV = 'LOCAL';

console.log(process.env.REACT_APP_ENV);

if (process.env.REACT_APP_ENV) {

// Dockerfile build 的時候替換環境

NOW_ENV = process.env.REACT_APP_ENV;

}

export const keys = {

SERVER_POINT: 'SERVER_POINT',

API_BASE_PORT: 'API_BASE_PORT'

};

const _valueSwitch = (value) => {

return _configValueSwitch(value, NOW_ENV);

};

  

const config = {};

Object.keys(keys).forEach((key) => {

config[key] = _valueSwitch(key);

});

  

export default config;
```

```js
import { keys } from './config';

  

const LOCAL = 'LOCAL';

const DEV = 'DEV';

const STAGE = 'STAGE';

const PROD = 'PROD';

const DOCKER = 'DOCKER';

const K8S = 'K8S';

let IP = '127.0.0.1';

// IP = '192.168.1.101'; // peja

  

export const configValue = (_target, _env) => {

let result;

switch (_target) {

case keys.SERVER_POINT:

if (_env === LOCAL) result = `ws://${IP}:8080/`;

if (_env === DEV) result = `wss://sample.com/`;

if (_env === STAGE) result = `wss://sample/`;

if (_env === PROD) result = `wss://sample/`;

break;

case keys.API_BASE_PORT:

if (_env === LOCAL) result = `8080`;

else if (_env === DOCKER) result = `8081`;

else if (_env === K8S) result = `30001`;

default:

break;

}

return result;

};

  

export default configValue;
```

應用的場景
```js
//在頂部import
 // 路徑依實際專案結構調整
import config from '../../config/config';

//如下
new SockJS(

`http://localhost:${getConfig.API_BASE_PORT}/stomp?userId=${userId}`

),
```

這樣就可以同時使用開發環境與其他環境有不同的  
port  
ip  
原始碼
[source code](<https://github.com/lipeijia/chat-room>) 