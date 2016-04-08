#!/usr/bin/env ruby
require 'open-uri'
require 'nokogiri'
require 'hipchat'
require 'slack'

# require token and room_name
require './config/config'
# include $sites
require './config/sites'

# p Slack.auth_test

def getTonarinoyjIdentifier(url)
  date = ''
  doc = Nokogiri::HTML(open(url))
  doc.xpath('//div[@class="single-update"]').each do |node|
    date = node.xpath(
      'dl[@class="home-manga-item-date home-manga-item-date--update"]/dd'
    ).children.text
  end
  date
end

def getIdentifier(url)
  doc = Nokogiri::HTML(open(url))
  doc.xpath('//div[@class="comicButtonDateBox"]/a')[0].text
end

$sites.each do |site|
  file = File.join('db', site[:file]);
  name = site[:name]
  url = site[:url]
  if name == 'onepanman'
    date = getTonarinoyjIdentifier url
  else
    date = getIdentifier url
  end

  if File.exist?(file) == false
    File.write(file, "no data")
  end
  prev_date = File.read(file, :encoding => Encoding::UTF_8)

  if date == ''
    p name + ' error'
    content = 'error' + ' ' + url
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
    File.write(file, date)
  else
    p name + ' no'
  end
end
__END__


