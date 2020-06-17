require 'net/http'
require 'thread'
require 'json'

@log_file= "log.txt"
currency_pair= "BTC-USD"
@price_api= "https://api.coinbase.com/v2/prices/#{currency_pair}/buy"
@seconds= 10
@coin_count= 0
@goal=nil
@a = nil
@b = nil

def get_average
    begin
        file_data = File.read(@log_file).split
         average= (file_data.map(&:to_f).reduce(:+) / file_data.size).to_i
        "Average since Program started is #{average}"
    rescue
        "Problem accessing log file"
    end
end

def time(n)
    if n.to_i !=  0   
        @seconds = n.to_i 
        Thread.kill(@a)
        @a = Thread.new { thread_A  }
    end
    "Price prints every #{@seconds}"
end

def worth(n)
    @coin_count = n.to_i if n.to_i !=  0   
    begin    
        btc=create_currency_pair('btc')
        total= @coin_count * coin(btc)[0]
        "The worth of #{@coin_count} is #{total}"
    rescue
        "API call Failed"
    end
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

def get_price(c = 'btc') 
    
    begin
        currency_pair = create_currency_pair(c)  
    rescue
        return "Coin not Valid"
    end
   
    begin
        price = coin(currency_pair) 
        puts "#{price[1]}: #{price[0]}"
    rescue
        "API call Failed"
    end

end

def create_currency_pair(coin)  
    coin= coin.upcase!
    coin.concat("-USD") 
end

def coin(currency_pair)

    price_api= "https://api.coinbase.com/v2/prices/#{currency_pair}/buy"
    uri = URI(price_api)
    res = Net::HTTP.get_response(uri)
    if res.is_a?(Net::HTTPSuccess)
        results = JSON.parse(res.body) 
        price = results["data"]["amount"].to_f
        append(price)
        return price, currency_pair
    end

end

def append(text)
    begin
        open(@log_file, 'a') do |f|
        f.puts text
        f.close
        end
    rescue
        puts "Could not log price"
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
        get_price(ext)
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
        sleep @seconds
        get_price
    end
end

def thread_B
    while true
        user_input
    end
end

File.delete(@log_file) if File.exist?(@log_file)

get_price
@a = Thread.new { thread_A  }
@b = Thread.new { thread_B  }

@a.join
@b.join
