#!/usr/bin/env ruby
# frozen_string_literal: true

require 'yaml'
require 'time'
require 'kramdown'
require 'builder'
require 'pathname'

JEKYLL_ROOT = ARGV[0] ? Pathname.new(ARGV[0]) : Pathname.pwd
POSTS_DIR   = JEKYLL_ROOT.join('_posts')
OUTPUT_FILE = (ARGV[1] || 'wordpress.xml')

abort "找不到 _posts 目錄：#{POSTS_DIR}" unless POSTS_DIR.directory?

def parse_post(path)
  raw = path.read.encode('UTF-8', invalid: :replace, undef: :replace, replace: '')
  fm, body = nil, raw
  if raw =~ /\A---\s*\n(.*?)\n---\s*\n/m
    fm   = YAML.safe_load($1, permitted_classes: [Date, Time], aliases: true) || {}
    body = $' # front-matter 之後的內容
  else
    fm = {}
  end

  # 由檔名取日期與 slug：YYYY-MM-DD-title.md
  fname = path.basename.to_s
  if fname =~ /\A(\d{4})-(\d{2})-(\d{2})-(.+)\.(md|markdown)\z/i
    date = Time.parse("#{Regexp.last_match(1)}-#{Regexp.last_match(2)}-#{Regexp.last_match(3)} 00:00:00")
    slug = Regexp.last_match(4)
  else
    date = Time.now
    slug = fname.sub(/\.(md|markdown)\z/i, '')
  end

  title = (fm['title'] || slug.tr('-', ' ')).to_s
  date  = Time.parse(fm['date'].to_s) rescue date
  cats  = Array(fm['categories'] || fm['category']).flatten.compact
  tags  = Array(fm['tags'] || fm['tag']).flatten.compact
  author = (fm['author'] || 'admin').to_s

  html = Kramdown::Document.new(body, input: :GFM).to_html

  {
    title: title,
    date:  date,
    slug:  slug,
    author: author,
    categories: cats,
    tags: tags,
    content_html: html
  }
end

posts = Dir[POSTS_DIR.join('**/*.{md,markdown}').to_s]
          .sort
          .map { |p| Pathname.new(p) }
          .map { |p| parse_post(p) }

xml = Builder::XmlMarkup.new(indent: 2)
xml.instruct! :xml, version: '1.0', encoding: 'UTF-8'
xml.rss('version' => '2.0',
        'xmlns:excerpt' => 'http://wordpress.org/export/1.2/excerpt/',
        'xmlns:content' => 'http://purl.org/rss/1.0/modules/content/',
        'xmlns:wfw'     => 'http://wellformedweb.org/CommentAPI/',
        'xmlns:dc'      => 'http://purl.org/dc/elements/1.1/',
        'xmlns:wp'      => 'http://wordpress.org/export/1.2/') do
  xml.channel do
    xml.title        'Jekyll Export'
    xml.link         'http://example.com'
    xml.description  'Exported from Jekyll'
    now = Time.now.utc
    xml.pubDate      now.rfc2822
    xml.tag!('wp:wxr_version', '1.2')
    xml.tag!('wp:base_site_url', 'http://example.com')
    xml.tag!('wp:base_blog_url', 'http://example.com')

    # 作者（可自行增加多位）
    xml.tag!('wp:author') do
      xml.tag!('wp:author_login', 'admin')
      xml.tag!('wp:author_email', 'admin@example.com')
      xml.tag!('wp:author_display_name') { xml.cdata! 'admin' }
      xml.tag!('wp:author_first_name')
      xml.tag!('wp:author_last_name')
    end

    posts.each_with_index do |post, i|
      xml.item do
        xml.title post[:title]
        xml.link  "http://example.com/#{post[:slug]}/"
        xml.pubDate post[:date].utc.rfc2822
        xml.tag!('dc:creator', post[:author])
        post[:categories].each { |c| xml.category('domain' => 'category', 'nicename' => c) { xml.cdata! c } }
        post[:tags].each       { |t| xml.category('domain' => 'post_tag', 'nicename' => t) { xml.cdata! t } }
        xml.guid('isPermaLink' => 'false') { xml.text! "jekyll-#{i}-#{post[:slug]}" }
        xml.description
        xml.tag!('content:encoded') { xml.cdata! post[:content_html] }
        xml.tag!('wp:post_id', i + 1)
        xml.tag!('wp:post_date', post[:date].strftime('%Y-%m-%d %H:%M:%S'))
        xml.tag!('wp:post_date_gmt', post[:date].getutc.strftime('%Y-%m-%d %H:%M:%S'))
        xml.tag!('wp:comment_status', 'open')
        xml.tag!('wp:ping_status', 'open')
        xml.tag!('wp:post_name', post[:slug])
        xml.tag!('wp:status', 'publish')
        xml.tag!('wp:post_parent', 0)
        xml.tag!('wp:menu_order', 0)
        xml.tag!('wp:post_type', 'post')
        xml.tag!('wp:post_password')
        xml.tag!('wp:is_sticky', 0)
      end
    end
  end
end

File.write(OUTPUT_FILE, xml.target!)
puts "Wrote #{OUTPUT_FILE} with #{posts.size} posts."
