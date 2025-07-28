---
tags:
  - java
title: Java Lambda介紹
created: 2025-07-27T15:00:00
modified: 2025-07-27T15:00:00
---
# 介紹
背後結合了 **函數式編程（Functional Programming）** 與 **物件導向** 的概念。它跟 C# 的 `delegate` 類似，但底層實作方式不同

# Lambda 模板

```java
(parameters) -> { statement }
```

使用心法
- 只有一行可以省略 `{}` 和 `return`
- 儘量搭配 `Stream API` 做資料處理
- 避免在 Lambda 裡寫太複雜的邏輯，保持簡潔

# Functional Interface 是什麼？
**Functional Interface 是一種“只定義一個抽象方法”的介面**，它可以：

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

# 實作 Functional Interface 的 3 種方式對比

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


## **Lambda 表達式的限制與注意事項**
- 無法直接丟 checked exception（需 try-catch 包起來或改成 unchecked）
- 不可使用非 final 或 effectively final 的外部區域變數（closure 限制）

```java
int x = 10;
Runnable r = () -> {
    // x++; //  編譯錯誤
    System.out.println(x); //  ok，因為 x 未被修改
};

Function<String, String> f = s -> {
    Thread.sleep(1000); //  sleep 會丟 InterruptedException（checked）
    return s;
};
```
### **Lambda 中只能使用 "final 或 effectively final" 的變數**

- Java 為了確保 Lambda 是 **可安全封閉（closure）**，不允許修改外部區域變數。
    
- 雖然你沒加 `final`，但只要沒改變它，Java 編譯器會**自動視為** `effectively final`。
    
- 一旦你想做 `x++`，它就不是 final，會 **編譯錯誤**。

### Lambda 表達式中不能直接丟出 **checked exception（受檢例外）**，除非顯式處理

Java 的內建函數式介面（像 `Function<T, R>`）**方法簽章並未宣告 throws**
- 所以你不能丟出任何 checked exception，否則會編譯錯。
- 若你真的需要，可以：
    - 包 try-catch（如上）
    - 使用自定義會 throws 的函數式介面（例如 `ThrowingFunction<T, R>`）

Thread.sleep
```java
public static void sleep(long millis) throws InterruptedException

```


## 總結對照表：

| 名稱                         | 是不是 Functional Interface？ | 是不是匿名類別？ | 說明                               |
| -------------------------- | ------------------------- | -------- | -------------------------------- |
| `MyFunction`（介面）           | 是                         |  否       | 定義一個函式介面                         |
| `new MyFunction() { ... }` | 實作了它                      | 是匿名類別    | 傳統 Java 寫法                       |
| `x -> x * x`               | 實作了它                      | 不是       | Lambda 寫法，JVM 用 invokedynamic 處理 |

## 常見 Java 函式式介面對照表


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


## 針對原始型別的特殊介面

|原始型別介面|方法|範例用途|
|---|---|---|
|`IntFunction<R>`|`R apply(int)`|`i -> "a" + i`|
|`IntConsumer`|`void accept(int)`|`i -> System.out.println(i)`|
|`IntPredicate`|`boolean test(int)`|`i -> i % 2 == 0`|
|`IntSupplier`|`int getAsInt()`|`() -> 42`|
|`IntUnaryOperator`|`int applyAsInt(int)`|`i -> i * i`|
|`IntBinaryOperator`|`int applyAsInt(int, int)`|`(a, b) -> a + b`|
