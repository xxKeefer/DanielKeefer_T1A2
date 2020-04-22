require "yaml"
module Util
  def populate(qty)
    player_db = {}
    qty.times do
      fake_user = Player.new()
      fake_user.name = "#{Faker::Creature::Animal.name.capitalize}#{Faker::Hacker.verb.capitalize}".split(/ /).join
      fake_user.id =fake_user.name+"##{rand(1000..9999)}"
      fake_pref = fake_user.roles[:options].shuffle
      fake_user.roles[:preferred] = fake_pref.pop
      fake_user.roles[:second] = fake_pref.pop
      fake_user.roles[:tank] = rand(500..4600)
      fake_user.roles[:damage] = rand(500..4600)
      fake_user.roles[:support] = rand(500..4600)
      fake_user.dossier[:endorsed][:punctual] = rand(0..50)
      fake_user.dossier[:endorsed][:high_skill] = rand(0..50)
      fake_user.dossier[:endorsed][:positivity] = rand(0..50)
      fake_user.dossier[:reported][:forfeits] = rand(0..50)
      fake_user.dossier[:reported][:low_skill] = rand(0..50)
      fake_user.dossier[:reported][:toxicity] = rand(0..50)
      player_db[fake_user.id] = fake_user
    end
    File.write("./db/player_db.yml", YAML.dump(player_db))
  end

  def initialize_db(name)
    if !(File.exists?("./db/#{name}_db.yml"))
      player_db = File.new("./db/#{name}_db.yml", "w")
      player_db.puts YAML.dump({})
      player_db.close
    end
  end

  def load_db(name)
    return YAML.load(File.read("./db/#{name}_db.yml"))
  end


end
