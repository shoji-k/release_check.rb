#!/usr/bin/env ruby
require 'open-uri'
require 'nokogiri'
require 'hipchat'
require 'slack'

require './config'

url = "http://urasunday.com/kengan/"
filename = "gengan-date.txt"

doc = Nokogiri::HTML(open(url))
chapter = doc.xpath('//div[@class="comicButtonDateBox"]/a')[0].text

if File.exist?(filename) == false
  File.write(filename, "no data")
end
prev_chapter = File.read(filename, :encoding => Encoding::UTF_8)

if chapter == ''
  content = 'error' + ' ' + url
  Slack.chat_postMessage(text: content, channel: $slack_room_name)
elsif prev_chapter != chapter
  if $notice_slack
    content = '[new]' + chapter + ' ' + url
    Slack.chat_postMessage(text: content, channel: $slack_room_name)
  end

  if $notice_hipchat
    client = HipChat::Client.new($token)
    client[$room_name].send("onepanman", msg, :notify => 1)
  end

  File.write(filename, chapter)
end

