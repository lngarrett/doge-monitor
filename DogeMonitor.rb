#DogeMonitor.rb
require './classes/User'
require 'csv'
require 'net/https'
require 'rubygems'
require 'json'

def getBalance(poolKey,poolID)
  @url = "https://doge.pool.pm/index.php?page=api&action=getuserstatus&api_key=" + poolKey + "&id=" + poolID
  uri = URI.parse(@url)
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  request = Net::HTTP::Get.new(uri.request_uri)
  response = http.request(request)
  parsed = JSON.parse(response.body)
  parsed["getuserstatus"]["data"]["transactions"]["Credit"]
end

def compareBalance(user,balance)
  @path = "./data/#{user}-ledger.csv"
  @lastRow
  begin
    CSV.foreach(@path) do |col|
      @lastRow = col[1].to_f
    end
  rescue
    @lastRow = -1
  end
  balance - @lastRow
end

def writeBalance(user,balance)
  @path = "./data/#{user}-ledger.csv"
  puts "Writing ledger for #{@user.name}"
  time = Time.now
    CSV.open(@path, "a+") do |csv|
      csv << [time.inspect, balance]
    end
end

def pushNotification(pushKey,comparedBalance)
  puts "Pushing to #{@user.name}"
  @appKey = "aMkBDCvh28xtQQX3rqdXu4HXYkU1qW"
  @pushBalance = comparedBalance.round
  url = URI.parse("https://api.pushover.net/1/messages.json")
  req = Net::HTTP::Post.new(url.path)
  req.set_form_data({
    :token => @appKey,
    :user => pushKey,
    :message => "New Block!\nMuch Doge: #{@pushBalance}",
  })
  res = Net::HTTP.new(url.host, url.port)
  res.use_ssl = true
  res.verify_mode = OpenSSL::SSL::VERIFY_PEER
  res.start {|http| http.request(req) }
end

CSV.foreach(File.path("./data/users.csv")) do |col|
  @user = User.new(col[0],col[1],col[2],col[3])
  @balance = getBalance(@user.poolKey,@user.poolID)
  @comparedBalance = compareBalance(@user.name,@balance)
  if @comparedBalance != 0
    puts "#{@user.name} dug up #{@comparedBalance} doge"
    writeBalance(@user.name,@balance)
    pushNotification(@user.pushKey,@comparedBalance)
  end
end
