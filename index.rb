require 'net/http'
require 'thread'
require 'json'



@log_file= "log.txt"
currency_pair= "BTC-USD"
@price_api= "https://api.coinbase.com/v2/prices/#{currency_pair}/buy"
@seconds= 10
@coin_count= 0
@goal=nil

def get_average
    file_data = File.read(@log_file).split
    average= (file_data.map(&:to_f).reduce(:+) / file_data.size).to_i
    "Average since Program started is #{average}"
end

def time(n)
    @seconds = n.to_i if n.to_i !=  0   
    "Price prints every #{@seconds}"
end

def worth(n)
    @coin_count = n.to_i if n.to_i !=  0   
    total= @coin_count * coin('btc')
    "The worth of #{@coin_count} is #{total}"
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
    price = coin('btc')
    if price 
       puts "BTC: #{price}"
       STDOUT.flush  
    else
        puts "API call failed"
        STDOUT.flush  
    end
end

def coin(c)
    return nil if c.nil?
        
    coin= c.upcase!
    currency_pair= coin.concat("-USD")

    price_api= "https://api.coinbase.com/v2/prices/#{currency_pair}/buy"
    uri = URI(price_api)
    res = Net::HTTP.get_response(uri)

    if res.is_a?(Net::HTTPSuccess)
        results = JSON.parse(res.body) 
        price = results["data"]["amount"].to_i
        append(price)
        return price
    else
        nil
    end

end

def append(text)
    open(@log_file, 'a') do |f|
       f.puts text
       f.close
    end
end

def exec_command(command, ext = nil)
    case command
    when "average"
        get_average
    when "time"
        time(ext)
    when "worth"
        worth(ext)
    when "alert"
        set_alert(ext)
    when "stop"
        stop_music
    when "now", "price"
        get_price
    when "alt"
        coin(ext)
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
        get_price
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
