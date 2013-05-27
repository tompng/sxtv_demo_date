require './lib/screenxtv'

module TerminalColor
  EMPHASIS = 1
  def self.grayscale(scale)
    "38;5;#{scale+240}"
  end
end

class Demo
  attr_accessor :stream, :prompt
  def initialize stream
    self.stream = stream
  end

  def wait(sec)
    sleep sec
  end


  def show str, fmt: nil, time: 0
    stream.data "\e[#{fmt}m" if fmt
    str.each_char do |c|
      c="\r\n" if c=="\n"
      stream.data c
      wait 0.1
    end
    stream.data "\e[m" if fmt
    wait time
  end

  def print str, time: 0
    stream.data str.gsub("\n","\r\n")
    wait time
  end

  def println str = '', time: 0
    stream.data "#{str}\n"
    wait time
  end

  def clear
    stream.data "\e[1;1H\e[2J"
  end
  def show_prompt time: 0
    print "#{prompt}", time: time
  end
end


class DateDemo < Demo
  LOGO = <<EOS
 ###                                 ##### #   #
#     ## # ##  ###   ###  # ##  #  #   #   #   #
 ##  #   ##   ##### ##### ##  #  ##    #    # #
   # #   #    #     #     #   #  ##    #    # #
###   ## #     ###   ###  #   # #  #   #     #
EOS

  VERY_SHORT = 0.2
  SHORT      = 1
  LONG       = 4

  def demo
    print LOGO, time: LONG
    show "The best way to broadcast your terminal to the world.\n",   time: SHORT
    show "Show your live coding for a study session or hackathon.\n", time: LONG
    show "\nInstall:\n", fmt: TerminalColor::EMPHASIS
    show_prompt time: SHORT
    show "gem install screenxtv", time: SHORT
    show "\n", time: LONG
    show "\nBroadcast:\n", fmt: TerminalColor::EMPHASIS
    show_prompt time: SHORT
    show "screenxtv "
    show "[--private]", fmt: TerminalColor.grayscale(10), time: SHORT
    println
    show_prompt time: SHORT
    show "clear\n", time: VERY_SHORT
    clear
    show_prompt
    show "date\n"
    println Time.now.strftime "%c"
    show_prompt time: SHORT
    show "echo Hello World!\n", time: VERY_SHORT
    println "Hello World!"
    show_prompt time: SHORT
    println
    show_prompt time: SHORT
    show "clock\n"
    20.times do
      print "\r\e[2K#{Time.now.strftime "%T"}", time: SHORT
    end
    println
    show_prompt time: SHORT
    show "clear\n", time: VERY_SHORT
    clear
  end

  def run
    loop { demo }
  end
end


ScreenXTV.configure do |config|
  config.host = 'localhost'
  config.port = 8000
end

channel = ScreenXTV::Channel.new
def $stdout.data(*args)
  $stdout.write *args
end
channel = $stdout

config = ScreenXTV::Config.new
config.public_url = 'hoge'

# channel.event do |k,v|
#   p [k,v]
# end

d=DateDemo.new channel
d.prompt="[\e[1mtompng\e[m:~]% "
d.run
# channel.start config do |channel, config|
#   d.run
# end

