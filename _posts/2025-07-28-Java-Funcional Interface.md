---
tags:
  - java
title: Java-Funcional Interface
created: 2025-07-28T08:57:32
modified: 2025-07-28T12:43:55
---
# 介紹

引入 **Functional Interface（函數式介面）** 的目的，主要是為了引進 **函數式編程（Functional Programming）** 的特性，並解決 Java 傳統物件導向程式設計的一些限制。這個改變是從 Java 8 開始的一個重大語言演進


## 1. 支援 Lambda 表達式
- Java 長期以來缺乏函數作為一等公民（first-class function），不能把行為當作參數傳遞。
    
- 為了支援 **Lambda 表達式（匿名函數）**，Java 必須有一種語法結構來接收「一段邏輯」作為參數 → 這就是函數式介面。
    
Functional Interface 是 Lambda 的語法依附對象。

請先參考 [Lambda 表達式介紹]({{ site.baseurl }}/Java-Lambda介紹/)。
##  2. 簡化匿名類別的繁瑣寫法
在 Java 8 以前，若要傳遞一段邏輯（例如事件處理、callback），只能寫匿名類別
```java
new ActionListener() {
    public void actionPerformed(ActionEvent e) {
        System.out.println("Clicked");
    }
};
//透過函數式介面 + Lambda
e -> System.out.println("Clicked");

```

- 更簡潔  
- 可讀性更高  
- 少寫很多 boilerplate code

## 3. 強化 API 的可組合性與彈性（如 Stream）
Java 8 新增的 `Stream API`、`Optional`、`CompletableFuture` 等都使用函數式介面來設計。

這讓邏輯可以像資料一樣「**流動與組合**」，提升 API 的表達力與擴展性

```java
list.stream()
    .filter(x -> x > 10)
    .map(x -> x * 2)
    .forEach(System.out::println);
```


## 4. 兼容物件導向與函數式風格
Java 沒有放棄 OOP，而是「**用 Functional Interface 作為橋梁**」，將兩種編程風格融合在一起
```java
// 接口仍是 class-based 的物件導向結構
@FunctionalInterface
interface MyFunction {
    int apply(int x);
    
// int doMore(int y); // ❌ 編譯會錯，因為違反 Functional Interface 要求
//只能有一個抽象方法
	}
}
```

## 5. 讓行為（函數）變成參數或變數
邏輯（方法）當作值傳遞，這實現了「行為即資料」的概念

```java
public static void doOperation(int x, Function<Integer, Integer> operation) {
    System.out.println(operation.apply(x));
}

doOperation(5, y -> y + 10);  // 輸出 15
```


# Functional Interface的實做

**是一種只定義一個抽象方法”的介面**，它可以：

- 由「具名類別」實作 
- 由「匿名類別」實作 
- 由「Lambda 表達式」實作 （Java 8+ 最簡潔的做法）


```java
@FunctionalInterface
interface MyFunction {
    int apply(int x);
}
```

特點：

- 只有**一個抽象方法**（比如 `apply()`）
- 可加 `@FunctionalInterface` 註解（非必要，但建議）
- 代表「可以被當作 Lambda 的目標」

## 實作 Functional Interface 的 3 種方式對比

1. 使用具名類別
```java
class Square implements MyFunction {
    @Override
    public int apply(int x) {
        return x * x;
    }
}
```
2. 使用匿名類別（Anonymous Class）
```java
@FunctionalInterface
MyFunction f = new MyFunction() {
    @Override
    public int apply(int x) {
        return x * x;
    }
};
```

3. 使用 Lambda（Java 8+ 最推薦）
```java
MyFunction f = x -> x * x;
```


三種寫法對應 Java 中實作 Functional Interface `Consumer<T>`

- `Consumer` 是「接受一個值但**不回傳**」的功能介面。
- 適用場景：列印、儲存、觸發副作用等。

```java
class test1 implements Consumer<Integer>{
	public void accept(Integer v){
	
	}
}

Consumer<Integer> _test1 = new Consumer<Integer>() {

	public void accept(Integer v){
	}

};

Consumer<Integer> _test1_1 = (Integer v) -> {};
```

## 對照表

| 寫法類型      | 程式碼範例                 | 優點        | 缺點                              |
| --------- | --------------------- | --------- | ------------------------------- |
| 具名類別      | `class Square ...`    | 清楚明確，便於除錯 | 程式碼冗長                           |
| 匿名類別      | `new MyFunction()...` | 不用額外類別名稱  | 結構仍冗長                           |
| Lambda 寫法 | `x -> x * x`          | 最簡潔，可讀性高  | 不能處理複雜邏輯、無法捕捉 checked exception |


# 策略模式的應用


```java
// 定義 Functional Interface
@FunctionalInterface
interface Strategy {
    int apply(int a, int b);
}
// 建立策略表

import java.util.Map;

//可換成 `new HashMap<>()` + `put()` 若需動態新增策略
// Map.of後若更動，將會報錯

Map<String, Strategy> strategyMap = Map.of(
    "add", (a, b) -> a + b,
    "sub", (a, b) -> a - b,
    "mul", (a, b) -> a * b,
    "div", (a, b) -> b != 0 ? a / b : 0
);

// 執行
public static int execute(String type, int a, int b, Map<String, Strategy> map) {
    Strategy strategy = map.get(type);
    if (strategy == null) {
        throw new IllegalArgumentException("未知策略：" + type);
    }
    return strategy.apply(a, b);
}

//測試

System.out.println(execute("add", 10, 5, strategyMap)); // 15
System.out.println(execute("mul", 10, 5, strategyMap)); // 50
System.out.println(execute("div", 10, 0, strategyMap)); // 0

```

注意
	可換成 `new HashMap<>()` + `put()` 若需動態新增策略
	Map.of後若更動，將會報錯
	


# 常見 Functional Interface  函式式介面對照表


| 類型    | 用途    | 介面                    | 方法名                | Lambda 範例          |
| ----- | ----- | --------------------- | ------------------ | ------------------ |
| 無參無回傳 | 執行動作  | `Runnable`            | `void run()`       | `() -> {...}`      |
| 有參無回傳 | 處理一個值 | `Consumer<T>`         | `void accept(T)`   | `x -> {...}`       |
| 雙參無回傳 | 處理兩個值 | `BiConsumer<T, U>`    | `void accept(T,U)` | `(a, b) -> {...}`  |
| 有參有回傳 | 單值轉換  | `Function<T, R>`      | `R apply(T)`       | `x -> result`      |
| 雙參有回傳 | 二元運算  | `BiFunction<T, U, R>` | `R apply(T, U)`    | `(a, b) -> result` |
| 判斷條件  | 回傳布林  | `Predicate<T>`        | `boolean test(T)`  | `x -> x > 0`       |
| 提供值   | 無參有回傳 | `Supplier<T>`         | `T get()`          | `() -> value`      |
| 同型轉換  | 一參有回傳 | `UnaryOperator<T>`    | `T apply(T)`       | `x -> x + 1`       |
| 同型轉換  | 兩參有回傳 | `BinaryOperator<T>`   | `T apply(T, T)`    | `(a, b) -> a + b`  |


# 針對原始型別的特殊介面

|原始型別介面|方法|範例用途|
|---|---|---|
|`IntFunction<R>`|`R apply(int)`|`i -> "a" + i`|
|`IntConsumer`|`void accept(int)`|`i -> System.out.println(i)`|
|`IntPredicate`|`boolean test(int)`|`i -> i % 2 == 0`|
|`IntSupplier`|`int getAsInt()`|`() -> 42`|
|`IntUnaryOperator`|`int applyAsInt(int)`|`i -> i * i`|
|`IntBinaryOperator`|`int applyAsInt(int, int)`|`(a, b) -> a + b`|
