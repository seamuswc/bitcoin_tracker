require 'net/http'
require 'thread'
require 'json'

=begin
This Program does the following:

1) Displays the bitcoin price at a time interval set by 'time -seconds'
'now', 'price' print immediate price

2) Displays what a certain amount of bitcoins are worth with 'worth -quantity'
It remebers previous worth entries and 'worth' will calculate based on the previous entered quantity.

3) You can set an alert with 'alert -price'
A song plays when this threshold is meet or passed.
'stop' stops the music and resets the alert amount to nil

4) 'average' get the average of all the prices printed since the start of the program.


=end

@log_file= "log.txt"
currency_pair= "BTC-USD"
@price_api= "https://api.coinbase.com/v2/prices/#{currency_pair}/buy"
@seconds= 10
@coin_count= 0
@goal=nil


def append(text)
    open(@log_file, 'a') do |f|
       f.puts text
       f.close
    end
end

def worth(n)
    @coin_count = n.to_i if n.to_i !=  0   
    @coin_count * get_price
end

def time(n)
    @seconds = n.to_i if n.to_i !=  0   
    "Price prints every #{@seconds}"
end

def set_alert(new_price)
    price = new_price.to_i
    @goal = price unless price <= 0
    case @goal
    when nil
        "Alert not set, must be more than 0"
    else
        "Alert set to #{@goal}"
    end
end

def alert(price)
    system('afplay rick_astley.mp3') if price >= @goal
end

def stop_music
    system('killall afplay')
    @goal=nil
    "Alert has been reset!"
end

def get_price
    uri = URI(@price_api)
    results =  JSON.parse(Net::HTTP.get(uri))
    price = results["data"]["amount"].to_i
    alert(price) if @goal != nil
    price
end

def spit_price
    price = get_price
    append(price)
    puts "BTC: #{price}"
    STDOUT.flush  
end

def get_average
    file_data = File.read(@log_file).split
    (file_data.map(&:to_f).reduce(:+) / file_data.size).to_i
end

def exec_command(command, ext = nil)
    case command
    when "average"
        "The average price is #{get_average}"
    when "time"
        time(ext)
    when "worth"
        "You have $#{worth(ext)}"
    when "alert"
        set_alert(ext)
    when "stop"
        stop_music
    when "now", "price"
        get_price
    else
        "Command not found"
    end
end

def user_input
    input = gets.chomp
    array = input.split('-')
    return if array.empty?
    if array.length != 2
        puts exec_command(array[0].strip)
    else
        puts exec_command(array[0].strip, array[1].strip)
    end
end

def thread_A
    while true
        spit_price
        sleep @seconds
    end
end

def thread_B
    while true
        user_input
    end
end

File.delete(@log_file) if File.exist?(@log_file)


a = Thread.new { thread_A  }
b = Thread.new { thread_B  }

a.join
b.join
