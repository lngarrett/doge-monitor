class User
  attr_accessor :name,:poolKey,:poolID,:pushKey
  def initialize(name,poolKey,poolID,pushKey)
    @name = name
    @poolKey = poolKey
    @poolID = poolID
    @pushKey = pushKey
  end
  def writeToCSV
    CSV.open("./data/users.csv","ab") do |csv|
      csv << [@name,@poolKey,@poolID,@pushKey]
    end
  end
end 
