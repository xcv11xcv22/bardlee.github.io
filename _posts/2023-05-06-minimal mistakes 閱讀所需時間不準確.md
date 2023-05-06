---
tags: [Jekyll]
title: minimal mistakes 閱讀所需時間不準確
created: '2023-05-06T12:05:43.588Z'
modified: '2023-05-06T15:53:14.336Z'
---

# minimal mistakes 閱讀所需時間不準確

## Jekyll語系
這問題是Jekyll語系的問題

在你的minimal mistakesa下的檔案 _includes\page__meta.html

主要是這一行

```html
assign words = document.content | strip_html | number_of_words 
```
words 是你的內文全部的字數

strip_html和number_of_words是Liquid Filters(液體過濾器(找不到中文譯名))

strip_html可以去除html的標籤

```html
Input
"Have <em>you</em> read <strong>Ulysses</strong>?" | strip_html 
Ouput
Have you read Ulysses?
```

關鍵是number_of_words

```html
Hello world!" | number_of_words 

2

 "你好hello世界world" | number_of_words 

1

"你好hello世界world" | number_of_words: "cjk" 

6
```
英文的話會以英文單詞為一個單位
無法辨識中文是一個字是一個單位

解決辦法是幫number_of_words加一個參數cjk

不過有一個難點
需要 Jekyll v4.1.0 以上

## Gemfile

目錄下的Gemfile

```ruby
source "https://rubygems.org"

gem "github-pages", group: :jekyll_plugins
gem "jekyll-include-cache", group: :jekyll_plugins
gem "webrick", "~> 1.8"

```
Bundler是ruby的套件，根據目錄中Gemfile的設定自動下載及安裝Gem套件

叫github-pages的Gem套件

目前github-pages 的版本號是228
有一個 jekyll = 3.9.3 的相依性套件

代表使用github-pages目前是無法套用number_of_words的參數的
因為版本太舊了

## 替代方法

目錄下的_config.yml

有一個叫words_per_minute的參數

根據_includes\page__meta.html
```html
words | divided_by: words_per_minute  site.data.ui-text[site.locale].minute_read | default: "minute read" 
```

可以發現words/words_per_minute，可以得出閱讀時間
所以我們可以透過調整words_per_minute的數值來達成比較準確的時間



