require 'open-uri'
require 'nokogiri'
require 'hipchat'

require './config'

doc = Nokogiri::HTML(open("http://urasunday.com/kurogane/"))
msg = doc.css('h3.h3Date')[0].text

filename = "kurogane-date.txt"
if File.exist?(filename) == false
  File.write(filename, "no data")
end
prev_msg = File.read(filename, :encoding => Encoding::UTF_8)

if prev_msg != msg
  client = HipChat::Client.new($token)
  # client['room'].send("ruby", "@all test message from ruby", :message_format => 'text', :color => 'purple', :notify => 1)

  client[$room_name].send("kurogane", msg, :notify => 1)

  File.write(filename, msg)
end

