#!/usr/bin/env ruby
require 'open-uri'
require 'nokogiri'
require 'hipchat'
require 'slack'
require 'watir'
require 'watir-webdriver'
require 'headless'

# require token and room_name
require './config/config'
# include $sites
require './config/sites'

# p Slack.auth_test

def getTonarinoyjIdentifier(url)
  $browser.goto url
  doc = Nokogiri::HTML.parse($browser.html)
  # doc = Nokogiri::HTML(open(url))
  doc.xpath('//dl[@class="home-manga-item-date home-manga-item-date--update"]/dd')[0].text
end

def getIdentifier(url)
  doc = Nokogiri::HTML(open(url))
  doc.xpath('//div[@class="comicButtonDateBox"]/a')[0].text
end

headless = Headless.new
headless.start
$browser = Watir::Browser.new :chrome

$sites.each do |site|
  file = File.join('db', site[:file]);
  name = site[:name]
  url = site[:url]

  date = nil
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

$browser.close
headless.destroy
__END__


