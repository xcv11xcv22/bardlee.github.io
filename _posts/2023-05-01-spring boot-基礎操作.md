---
tags: [spring boot]
title: spring boot-基礎操作
created: '2023-04-28T10:28:35.043Z'
modified: '2023-05-01T11:17:26.433Z'
---

# spring boot-基礎操作


## MVC
Spring boot 也有MVC的架構
簡單來說就是將資料、處理資料的流程、視覺三方的關注點分開
讓彼此間的關係程度分開一些

## spring ioc
spring ioc控制反轉容器，這是一轉設計模式，可以參考[維基百科](https://zh.wikipedia.org/zh-tw/%E6%8E%A7%E5%88%B6%E5%8F%8D%E8%BD%AC)
簡單來說
我們定義三個類別
ClassRoom
Teacher
Student

在ClassRoom類別裡面去實例化Teacher和Student物件
要開始教學，那我需要Teacher物件的的合作
不過問題來了，因為我們是在ClassRoom類別裡面實例化的
如果我有很多類別都這樣設計的呢
那麼相互間的關係會錯綜複雜，各自間都有自己的耦合，後期多了之後
會難以維護

spring ioc會自動處理物件的實例化並管理，減輕你內別內住的負擔
當你下了@Component類型的注釋，一個spring bean的物件就會被建立出來
並且注入到類別的變數裡面

## spring boot 的 annotation

* @Controller
類別的注釋，容納一個Model物件，可以幫助我們資料與畫面的
連結，並且方法會預設跟視圖連結，搜尋你指定的html
* @ResponseBody
類別和方法的注釋，可以指示Controller以JSON或其他資料導向格式
來回傳一個格式化的回應
* @RestController
類別的注釋，@Controller與@ResponseBody的結合，可以幫你
節省程式碼，REST API的好幫手

## 常用的http動詞
REST API的設計是在下列的基礎之上
* GET(讀取)
* POST(建立)
* PUT(更新)
* PATCH(更新)
* DELETE(刪除)

## 以Spring boot的注釋來建立動詞

* @RequestMapping
類別和方法的注釋
有兩個重要參數
value是 url
method是http動詞，叫做RequestMethod的列舉

@RequestMapping有幾個特化的注釋，都是用在方法的
* @GetMapping  
* @PostMapping
* @PutMapping
* @PatchMapping
* @DeleteMapping
這些注釋各自對應到相應的動詞，並且只需要給url的參數就好








