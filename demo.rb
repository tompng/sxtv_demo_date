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

  def showln str = '', fmt: nil, time: 0
    show "#{str}\n", fmt: fmt, time: time
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

  def logo
    print LOGO, time: LONG
  end

  def describe_screenxtv
    showln "The best way to broadcast your terminal to the world.",   time: SHORT
    showln "Show your live coding for a study session or hackathon.", time: LONG
    showln
  end

  def how_to_install
    showln "Install:", fmt: TerminalColor::EMPHASIS
    show_prompt time: SHORT
    show "gem install screenxtv", time: SHORT
    showln time: LONG
    showln
  end

  def how_to_broadcast
    showln "Broadcast:", fmt: TerminalColor::EMPHASIS
    show_prompt time: SHORT
    show "screenxtv "
    show "[--private]", fmt: TerminalColor.grayscale(10), time: SHORT
    println
  end

  def clock_demo
    show_prompt time: SHORT
    showln "clock"
    20.times do
      print "\r\e[2K#{Time.now.strftime "%T"}", time: SHORT
    end
    println
  end

  def helloworld_demo
    show_prompt time: SHORT
    showln "echo Hello World!", time: VERY_SHORT
    println "Hello World!"
  end

  def empty_demo
    show_prompt time: SHORT
    println
  end

  def clear_demo
    show_prompt time: SHORT
    showln "clear", time: VERY_SHORT
    clear
  end

  def date_demo
    show_prompt
    showln "date"
    println Time.now.strftime "%c"
  end

  def demo
    logo

    describe_screenxtv

    how_to_install

    how_to_broadcast

    clear_demo

    date_demo

    helloworld_demo

    empty_demo

    clock_demo

    clear_demo
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

config = ScreenXTV::Config.new
config.public_url = 'hoge'

channel.event do |k,v|
  p [k,v]
end

d=DateDemo.new channel
d.prompt="[\e[1mtompng\e[m:~]% "

channel.start config do |channel, config|
  channel.winch 80,24
  d.run
end

