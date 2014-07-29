require 'open-uri'
require 'nokogiri'
require 'hipchat'

# Hipchat token
token = "############################"

# Hipchat room name
room_name = 'sign'

doc = Nokogiri::HTML(open("http://tonarinoyj.jp/manga/"))
onepanman = doc.css('div.item')[9]

msgs = onepanman.css('dd > strong').map do |node|
  node.text
end
msg = msgs.shift

filename = "release-date.txt"
if File.exist?(filename) == false
    File.write(filename, "no data")
end
prev_msg = File.read(filename, :encoding => Encoding::UTF_8)

if prev_msg != msg
    client = HipChat::Client.new(token)
    # client['room'].send("ruby", "@all test message from ruby", :message_format => 'text', :color => 'purple', :notify => 1)

    client[room_name].send("onepanman", msg, :notify => 1)

    File.write(filename, msg)
end


