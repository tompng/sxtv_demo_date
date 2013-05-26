require './lib/screenxtv'

class Demo
  attr_accessor :stream, :prompt
  def initialize stream
    self.stream = stream
  end
  def show str, fmt=nil
    stream.data "\e[#{fmt}m" if fmt
    str.each_char do |c|
      c="\r\n" if c=="\n"
      stream.data c
      sleep 0.1
    end
    stream.data "\e[m" if fmt
  end
  def print str
    stream.data str.gsub("\n","\r\n")
  end
  def clear
    stream.data "\e[1;1H\e[2J"
  end
  def show_prompt
    print "#{prompt}"
  end
end


class DateDemo < Demo
  def run
    loop do
logo=<<EOS
 ###                                 ##### #   #
#     ## # ##  ###   ###  # ##  #  #   #   #   #
 ##  #   ##   ##### ##### ##  #  ##    #    # #
   # #   #    #     #     #   #  ##    #    # #
###   ## #     ###   ###  #   # #  #   #     #
EOS
      print logo
      sleep 4
      show "The best way to broadcast your terminal to the world.\n"
      sleep 1
      show "Show your live coding for a study session or hackathon.\n"
      sleep 4
      show "\nInstall:\n", 1
      show_prompt
      sleep 1
      show "gem install screenxtv"
      sleep 1
      show "\n"
      sleep 4
      show "\nBroadcast:\n", 1
      show_prompt
      sleep 1
      show "screenxtv "
      show "[--private]", '38;5;250'
      sleep 1
      show "\n"
      show_prompt
      sleep 1
      show "clear\n"
      sleep 0.2
      clear
      show_prompt
      show "date\n"
      print "#{Time.now.strftime "%c"}\n"
      show_prompt
      sleep 1
      show "echo Hello World!\n"
      sleep 0.2
      print "Hello World!\n"
      show_prompt
      sleep 1
      print "\n"
      show_prompt
      sleep 1
      show "clock\n"
      20.times do
        print "\r\e[2K#{Time.now.strftime "%T"}"
        sleep 1
      end
      print "\n"
      show_prompt
      sleep 1
      show "clear\n"
      sleep 0.2
      clear
    end
  end
end


ScreenXTV.configure do |config|
  config.host = 'localhost'
  config.port = 8000
end

channel = ScreenXTV::Channel.new

config = ScreenXTV::Config.new
config.public_url = 'hoge'

channel.event do |k,v|
  p [k,v]
end

d=DateDemo.new channel
d.prompt="[\e[1mtompng\e[m:~]% "
channel.start config do |channel, config|
  d.run
end

