---
tags: [spring boot]
title: spring boot-啟動資料庫
created: '2023-05-01T11:16:26.717Z'
modified: '2023-05-05T15:23:40.505Z'
---

# spring boot-啟動資料庫

## 自動組態簡化程式碼的流程
存取資料庫這個流程，很多SOP都是一樣的，不過根據不同的資料庫

可能就讓人覺得有點煩躁，因為只有一些不同

Spring boot的自動組態會去偵測你的設定，合理的幫你建立出適合

Bean，我們需要做的事情就是把自訂的組態寫好即可

## Hibernate
Hibernate是一種Java語言下的物件關係對映（ORM）解決方案，不只
Java類別到資料庫的映射，還有Java類別到資料庫型別的映射

## Spring Data
Spring Data是一個提通基於spring的程式模型而且同時也保持底層所使用
資料庫的特徵，讓你可以更容易的操作資料庫


## 如何加入到組態

* 選擇一個Spring Data模組
  * Spring Data JPA
  * Spring Data KeyValue
  * Spring Data LDAP
  * Spring Data MongoDB
  * Spring Data Redis

* 資料庫廠商會提供資料庫驅動程式，讓你能利用程式去存取


## Spring Data JPA
Spring Data JPA是在Jpa的規範上封裝的應用規範

當我們使用JPA模組，就要選擇與JPA有依存關係的

資料庫，並挑選特定的驅動程式

只要你是使用JPA模組，你就可以與其他相容於JPA的資料庫(如MySql, PostgreSQL)

## H2
H2是一個Java編寫的關係型資料庫，它可以被嵌入Java應用程式中使用，或者作為一個單獨的資料庫伺服器執行

H2是滿方便的資料庫，它可以基於硬碟儲存，不過當你改成其它JPA的資料庫時

程式碼不需要變更，以測試來說是相當方便的

Maven設定參考如下
```xml
<dependency>
  <groupId>org.springframework.boot</groupId>
  <artifactId>spring-boot-starter-data-jpa</artifactId>
</dependency>

<dependency>
  <groupId>com.h2database</groupId>
    <artifactId>h2</artifactId>
    <scope>runtime</scope>
  </dependency>
<dependency>
```
## MySql

spring.jpa.hibernate.ddl-auto=update
spring.datasource.url=jdbc:mysql://localhost:3306/your_db_name
spring.datasource.username=user
spring.datasource.password=123456
spring.datasource.driver-class-name=com.mysql.cj.jdbc.Driver

* spring.jpa.hibernate.ddl-auto 可被設定成 none, update, create, or create-drop
  * none: MySQL 的默認值。沒有對數據庫結構進行任何更改
  * update: Hibernate 根據給定的實體結構更改數據庫
  * create: 每次都創建數據庫但不會在關閉時刪除它
  * create-drop: 創建數據庫並在 SessionFactory 關閉時刪除它。

剛開始還未有資料庫時，請選擇create or update，當你運行過友資料庫之後使用update or none，
當你資料庫想更新時請使用update

H2和其它嵌入式資料庫預設是create-drop，其它資料庫如MySql，預設是none

你通常不需要指定驅動程序類名(spring.datasource.driver-class-name)
，因為 Spring boot 可以從 url 為大多數數據庫推斷出它

## 為類別加入映射

```java
@Entity
public class Car {
    @Id
    private  String id;
    private String name;
}
```

@Entity: 指示該類別是一個可以續存的實體
@Id: 只要類別有注釋Entity，你必須給一個@Id注釋，這個相當於table的primary key

### 存取Entity
你應該有注意到類別的成員變數是私有的，這樣會讓JPA無法存取物件的值
有兩個解法
1. 宣告成public
2. 使用public變動器方法

```java
public void  setId(String id){
  this.id = id;
}
public String  getId(){
  return this.id;
}
```
注意，命名要使用set + 變數名

##  儲存庫(Repository)

定義一個變數給儲存庫，

Repository是一個泛型Pair介面，可以參考我的[文章介紹](/Java-泛型/#多重型態參數)
它定義的兩種型態分別是要儲存的物件型別，以及其Primary Key

Repository 是在Spring Data 裡面的一個介面，可以透過這個介面，對資料庫
進行操作

### CrudRepository
CrudRepository 是繼承了Repository介面，定義了幾種基本的CRUD功能，可以
針對簡單的應用程式做操作

```java
public interface CrudRepository<T, ID> extends Repository<T, ID> {
  <S extends T> S save(S entity);

  <S extends T> Iterable<S> saveAll(Iterable<S> entities);

  Optional<T> findById(ID id);

  boolean existsById(ID id);

  Iterable<T> findAll();

  Iterable<T> findAllById(Iterable<ID> ids);

  long count();

  void deleteById(ID id);

  void delete(T entity);

  void deleteAllById(Iterable<? extends ID> ids);

  void deleteAll(Iterable<? extends T> entities);

  void deleteAll();
}

```
這個是這個介面定義的的方法，我們挑幾個來看如何實現Crud

Create:
```java
<S extends T> S save(S entity);
<S extends T> Iterable<S> saveAll(Iterable<S> entities);
```

Read:
```java
Iterable<T> findAll();
Iterable<T> findAllById(Iterable<ID> ids); 
```
Update:
更新需要注意多一些東西
用跟Create一樣的方法就可以了

用save就可以了，也可以加上HttpStatus去告知前端你的狀態
是新增還是更新

還記得epository是Pair介面吧，Save底層肯定是利用ID的值
去實現共用新增與更新

Delete:
```java
void deleteAllById(Iterable<? extends ID> ids);

void deleteAll(Iterable<? extends T> entities);

void deleteAll();
```

## 自動組態的連線

Spring boot會根據我們設定的資料庫驅動程式與Repository介面
與Jpa Entiry去幫我們建立一個Database bean

可以使用可以使用建構式實現自動注入

```java
interface CarRepository extends CrudRepository<Car, String>{}

@RestController
class CarController{
    private final CarRepository carRepository;
    public CarController(CarRepository carRepository){
        this.carRepository = carRepository;
    }

}
```



