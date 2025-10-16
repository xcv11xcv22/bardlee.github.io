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


# 方法參考（Method Reference）
**方法參考**是 Java 8 引入的一種 **簡化 Lambda 表達式的語法**
 當 Lambda 的內容只是「**直接呼叫某個已存在的方法**」時，可以用 `::` 替代

```java
//靜態方法參考----------------------------
public class Utils {
    public static boolean isPositive(int x) {
        return x > 0;
    }
}
//執行
Predicate<Integer> p = Utils::isPositive;
// 相當於：x -> Utils.isPositive(x)
System.out.println(p.test(10)); // true

//物件實例方法參考----------------------------
public class Printer {
    public void print(String s) {
        System.out.println(">> " + s);
    }
}
//執行
Printer printer = new Printer();
Consumer<String> c = printer::print;
// 相當於：s -> printer.print(s)
c.accept("Hello");

//類別的實例方法參考（重點）----------------------------
List<String> list = Arrays.asList("a", "b", "c");
list.forEach(System.out::println);
// 相當於：s -> System.out.println(s)
//or
BiPredicate<String, String> equals = String::equals;
// 相當於：(a, b) -> a.equals(b)

//建構子參考----------------------------
Supplier<List<String>> listSupplier = ArrayList::new;
List<String> list = listSupplier.get(); // new ArrayList()


```

## 關於類別的實例方法參考

### 為什麼能用在 `list.forEach(System.out::println)`？
- `forEach` 方法需要一個 **`Consumer<T>`** 介面實作。
- `Consumer<T>` 是一個 **函式式介面**，定義方法：
```java
void accept(T t);
```
- `System.out::println` 實際上是「指向 `PrintStream` 物件的 `println` 方法」的**方法參考**，
- 它的簽名跟 `Consumer<String>` 的 `accept(String)` 一致，  
    因此可以視為一個 `Consumer<String>` 實例（底層由 JVM 幫你轉換）。
    
- **`System.out::println` 是一個方法參考（method reference），符合 Lambda 所要求的函式介面（Consumer）的單一抽象方法簽名**。
- 它本質上是符合 `Consumer<String>` 的實作，可以賦值給該介面型態的變數或參數。

### 自轉轉換的條件

JVM（編譯器）自動轉換的條件：
- 只要 **你的目標類型是 Functional Interface**，且Lambda 表達式或方法參考的**簽名（參數和回傳型態）符合該介面唯一抽象方法的簽名**
---

#### 詳細說明：
- **函式介面（Functional Interface）**：必須有且只有一個抽象方法
    
- **Lambda 表達式或方法參考**：編譯器會檢查它們的參數與回傳型態，是否可以對應介面方法
    
- **只要匹配，就會自動幫你轉換成該介面的實例**


## BiPredicate<String, String> equals = String::equals說明
`BiPredicate<T, U>` 介面有一個抽象方法


```java

//`BiPredicate<T, U>` 介面有一個抽象方法
boolean test(T t, U u);

//執行
boolean result1 = equals.test("hello", "hello"); // true
boolean result2 = equals.test("hello", "world"); // false
```


**小結**

| 類型         | 語法                       | 參考範例                  | 解釋                         |
| ---------- | ------------------------ | --------------------- | -------------------------- |
| 靜態方法       | `Class::staticMethod`    | `Math::abs`           | x -> Math.abs(x)           |
| 特定物件方法     | `object::instanceMethod` | `System.out::println` | x -> System.out.println(x) |
| 類別實例方法     | `Class::instanceMethod`  | `String::toUpperCase` | x -> x.toUpperCase()       |
| 類別實例方法（二參） | `String::equals`         | (a, b) -> a.equals(b) |                            |
| 建構子        | `Class::new`             | `ArrayList::new`      | () -> new ArrayList<>()    |

# **Lambda 表達式的限制與注意事項**
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
## **Lambda 中只能使用 "final 或 effectively final" 的變數**

- Java 為了確保 Lambda 是 **可安全封閉（closure）**，不允許修改外部區域變數。
    
- 雖然你沒加 `final`，但只要沒改變它，Java 編譯器會**自動視為** `effectively final`。
    
- 一旦你想做 `x++`，它就不是 final，會 **編譯錯誤**。

## Lambda 表達式中不能直接丟出 **checked exception（受檢例外）**，除非顯式處理

Java 的內建函數式介面（像 `Function<T, R>`）**方法簽章並未宣告 throws**
- 所以你不能丟出任何 checked exception，否則會編譯錯。
- 若你真的需要，可以：
    - 包 try-catch（如上）
    - 使用自定義會 throws 的函數式介面（例如 `ThrowingFunction<T, R>`）

Thread.sleep
```java
public static void sleep(long millis) throws InterruptedException

```

