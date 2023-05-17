---
tags: [javascript]
title: this與javascript
created: '2023-05-16T19:52:10.241Z'
modified: '2023-05-17T14:07:31.710Z'
---

# this與javascript

## this在全域上使用

```javascript
function test1(){
    this.name = "jack";
    console.log(this);
}
var obj_1 = {
    name :"jack",
    fn1 : function(){
        console.log(this);
    }
};
class ClassJack {
    constructor() {
        this.name = "jack";
        console.log(this);
    }
}


test1();  //直接呼叫
new test1(); //實例化 主要是觀察使用實例化會不會改變this指向
obj_1.fn1(); //使用物件呼叫
new ClassJack(); //新語法實例化

//output

global {global: global, clearInterval: ƒ, clearTimeout: ƒ, setInterval: ƒ, setTimeout: ƒ, …}

test1 {name: 'jack'}

{name: 'jack', fn1: ƒ}

ClassJack {name: 'jack'}

```
主要是看最後一個呼叫方法的物件，如果沒有的話就是global

如果實例化，this就會指向實例化的物件


## 更深層的this

```javascript
var jack_1 = {
    name : 'jack1',
    fn1 : function(){
        console.log(this.name);
    }
};

var jack_2 = {
    name : 'jack2',
    fn1 : function(){
        jack_1.fn1();
    }
};

var jack_3 = {
    fn1 : function(){
        name : 'jack3',
        var fn2 = jack_1.fn1;
        fn2();
    }
};

jack_1.fn1();
jack_2.fn1();
jack_3.fn1();

output

(2)jack
undefined
```


jack_1.fn1();  
輸出是jack

jack_2.fn1();  
剛剛有提過，this會指向最後呼叫的物件  
this 指向 jack_1  
因此輸出也是jack

jack_3.fn1();  
這邊是在方法fn1裡面宣告fn2區域變數  
fn2取得jack_1.fn1的參考  
但fn2並不是某物件的方法，所以this會指向global  
global沒有定義name，因此是undefined

## call、applay、bind 與 this

```javascript
function callFn(){
    var name = "jack";
    console.log(this.name);
}

var jack_4 = {
    name: "jack4"
};


global.name = 'brown';
callFn.call(jack_4);
var  callFn1 = callFn.bind(jack_4);
callFn1();
callFn.apply(jack_4);
callFn.apply(null);

output

(3)jack4
brown

```


第一個參數是this的執行環境  
若這個函數是在非嚴苛模式並且第一個參數是null 、undefined 將會被置換成全域變數，而原生型態的值將會被封裝

這是mdn的解釋  
我是理解是如果被取代，那原本的值會被隱藏起來

## 匿名方法與this

```javascript
var FnTest1 = function (callback){
    callback();
}
var obj_3 = {
    name : 'obj_3',
    fn1 : function(){
        setTimeout(function(){
            console.log(this);
        }, 500)
    },
    fn2 : function() {
            setTimeout(() =>{
            console.log(this);
        }, 500);
    },
    fn3 : function(){
        FnTest1(function(){
            console.log(this);
        });
    }
};

obj_3.fn1();
obj_3.fn2();
obj_3.fn3();

output

global {global: global, clearInterval: ƒ, clearTimeout: ƒ, setInterval: ƒ, setTimeout: ƒ, …}
this.js:81

Timeout {_idleTimeout: 500, _idlePrev: null, _idleNext: null, _idleStart: 165, _onTimeout: ƒ, …}
this.js:71

{name: 'obj_3', fn1: ƒ, fn2: ƒ, fn3: ƒ}
```


第一個輸出是fn3  
因為匿名方法沒有上一個呼叫的物件，所以就變成全域的呼叫  
this就指向global

第二個輸出是fn1  
這個匿名方法的輸出竟然是Timeout物件，有可能global的setTimeout方法  
實際上是由global的Timout物件去呼叫此方法  
所以this才指向Timeout

第三個輸出是fn2  
不過如果把this指向目前方法所在的物件，不想要讓this指向呼叫它的物件  
可以使用箭頭方法去指向匿名方法  
即可完成this的轉向




