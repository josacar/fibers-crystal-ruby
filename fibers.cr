require "http/client"
require "benchmark"

Benchmark.bm do |x|
  x.report("sync") do
    puts HTTP::Client.get("http://checkip.amazonaws.com/").body
    puts HTTP::Client.get("https://wtfismyip.com/text").body
  end

  x.report("async") do
    channel = Channel(String).new

    spawn do
      puts HTTP::Client.get("http://checkip.amazonaws.com/").body
      puts "async: amazonaws"
      channel.send("amazonaws")
    end

    spawn do
      puts HTTP::Client.get("https://wtfismyip.com/text").body
      puts "async: wtfismyip"
      channel.send("wtfismyip")
    end

    2.times do
      puts channel.receive
    end
  end
end
