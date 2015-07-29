#!/usr/bin/env ruby
require 'open-uri'
require 'nokogiri'
require 'hipchat'
require 'slack'

# require token and room_name
require './config'

url = "http://tonarinoyj.jp/manga/onepanman/"
filename = "onepanman-date.txt"

date = ''
doc = Nokogiri::HTML(open(url))
doc.xpath('//div[@class="single-update"]').each do |node|
  date = node.xpath(
    'dl[@class="home-manga-item-date home-manga-item-date--update"]/dd'
  ).children.text
end

if File.exist?(filename) == false
  File.write(filename, "no data")
end
prev_date = File.read(filename, :encoding => Encoding::UTF_8)

if date == ''
  content = '取得失敗' + ' ' + url
  Slack.chat_postMessage(text: content, channel: $slack_room_name)
elsif prev_date != date
  if $notice_slack
    content = '[new]' + date + ' ' + url
    Slack.chat_postMessage(text: content, channel: $slack_room_name)
  end

  if $notice_hipchat
    client = HipChat::Client.new($token)
    client[$room_name].send("onepanman", msg, :notify => 1)
  end

  File.write(filename, date)
end

