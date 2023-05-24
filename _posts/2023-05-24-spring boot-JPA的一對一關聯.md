---
tags: [spring boot]
title: spring boot-JPA的一對一關聯
created: '2023-05-23T05:51:26.591Z'
modified: '2023-05-24T10:26:41.927Z'
---

# spring boot-JPA的一對一關聯

首先，使用方便測試的H2

pom.xml:
```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-data-jpa</artifactId>
</dependency>
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-web</artifactId>
</dependency>

<dependency>
    <groupId>com.h2database</groupId>
    <artifactId>h2</artifactId>
    <scope>runtime</scope>
</dependency>



```

application.properties:
spring.datasource.url=jdbc:h2:mem:testdb

要設計的Schema是

User1 <- Address 一對一

| User1 |
|---|
|id|
|name|
|address_id|

| Address |
|---|
|id|
|address|


```java
@Entity
@Table(name = "user1")
public class User1 {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    public Long id;
    public String name;
    public User1(String name){
        this.name = name;
    }
    @OneToOne(cascade = CascadeType.ALL)
    @JoinColumn(name = "address_id", referencedColumnName = "id")
    public Address address;
    public User1(){}
}

@Entity
public class Address {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    public Long id;
    public String address;

    public Address(String address){
        this.address = address;
    }
    public Address() {}
}
```

@OneToOne(cascade = CascadeType.ALL)  
對於這實體的關聯操作，CascadeType.ALL表示任何操作當會影響到另一個一對一實體

@JoinColumn(name = "address_id", referencedColumnName = "id")  
name的值是會在此資料表設立一個address_id外鍵  
referencedColumnName是對對象Entity也就是address的id 作為參考

## 關於外鍵的位置
我有思考過把外鍵放到address會如何，也是可以work  
不過有一個問題是  
User1的實體會沒有外鍵的資料，會使的操作比較麻煩，但有補救的方法

使用OneToOne的屬性mappedBy  
就可以讓欄位有關聯的反向端獲得參考

再看看官方JoinColumn name的說明  
If the join is for a OneToOne or ManyToOne mapping using a foreign key mapping strategy,  
the foreign key column is in the table of the source entity or embeddable.

source entity上述沒有說是什麼  
根據我的判斷指的是關聯資料表to的左邊，OnetoOne左邊放外鍵也會比較方便

## 程式碼

Controller
```java
@RestController
public class MyCtrl {
    private final AddressRepository addressRepository;
    private final User1Repository user1Repository;
    public MyCtrl(AddressRepository addressRepository, User1Repository user1Repository){
        this.addressRepository = addressRepository;
        this.user1Repository = user1Repository;
        User1 u1 = this.user1Repository.save(new User1("Lee"));
        Address d1 = addressRepository.save( new Address("Taipei"));
        u1.address = d1;
        user1Repository.save(u1);

        addressRepository.deleteById("1");
        user1Repository.deleteById("1");
    }
}
```
Repository
```java
public interface User1Repository extends CrudRepository<User1, String> {}
public interface AddressRepository extends CrudRepository<Address, String> {}
```
經過上面的設定，已經有外鍵限制了

addressRepository.deleteById("1");  
這一行就會有錯誤，因為限制

user1Repository.deleteById("1");  
這一行執行完，不只user1會被刪掉，關聯的address也會一起被刪掉








