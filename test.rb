require 'net/http'
require 'thread'
require 'json'

def coin(c)
    puts "Coin is not listed on Coinbase" and return if c.nil?
    coin= c.upcase!
    currency_pair= coin.concat("-USD")

    price_api= "https://api.coinbase.com/v2/prices/#{currency_pair}/buy"
    uri = URI(price_api)
    res = Net::HTTP.get_response(uri)

    if res.is_a?(Net::HTTPSuccess)
        results = JSON.parse(res.body) 
        price = results["data"]["amount"].to_i
        puts price
    else
        puts "Request Failed"
    end

end

def exec_command(command, ext = nil)
    case command
    when "new"
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


#main()
    while true
        user_input
    end

