---
layout: archive
permalink: /tags/
title: Tags
author_profile: true
---


<div id="archives">
{% for category in site.tags %}
  <div class="archive-group">
    {% capture tag_name %}{{ category | first }}{% endcapture %}
    <div id="#{{ tag_name | slugize }}"></div>
    <p></p>

    <h3 class="tag-head">{{ tag_name }}</h3>
    <a name="{{ tag_name | slugize }}"></a>
    {% for post in site.tags[tag_name] %}
    <article class="archive-item">
      <h4><a href="{{ site.baseurl }}{{ post.url }}">{{post.title}}</a></h4>
    </article>
    {% endfor %}
  </div>
{% endfor %}
</div>