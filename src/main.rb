require "tty-prompt"
require "yaml"
require 'faker'

require_relative "./classes/player.rb"

menu = TTY::Prompt.new

puts `clear`

quit = false
until quit
  case menu.select("Welcome to Overwatch Event Planner!",
     ["Player Management",
       "Event Management",
       "[Dev] Populate DB",
       "Quit"])

  when "Player Management"
    if !(File.exists?("./db/player_db.yml"))
      player_db = File.new("./db/player_db.yml", "w")
      player_db.puts YAML.dump({})
      player_db.close
    end
    while true

       case menu.select("Player Management Menu",
         ["Create / Edit Player",
           "Search for Player",
            "Display All Players",
            "Back to Main Menu"])

       when "Create / Edit Player"
         player_db = YAML.load(File.read("./db/player_db.yml"))
         new_user = Player.new()
         new_user.registration
         if player_db.has_key?(new_user.id)
           if menu.yes?("Player #{new_user.id} already exists, overide information?")
             player_db["#{new_user.id}"] = new_user
             File.write("./db/player_db.yml", YAML.dump(player_db))
             puts "#{new_user.id}'s Info Updated!"
           else
             puts "Player Data Discarded."
           end
         else
           player_db["#{new_user.id}"] = new_user
           File.write("./db/player_db.yml", YAML.dump(player_db))
           puts "Database updated!"
         end

       when "Search for Player"
         #search_player function
         player_db = YAML.load(File.read("./db/player_db.yml"))
         user = menu.ask ("Which player?") do |q|
            q.required true
            q.validate /\A[\w\d]{1,15}#\d{4,5}\Z/
          end
          if player_db.has_key?(user)
            player_db[user].print_info
          else
            menu.error("Player #{user} does not exist in database.")
          end

       when "Display All Players"
         #print player to screen
         player_db = YAML.load(File.read("./db/player_db.yml"))
         player_db.each { |k,v| v.print_info  }
       else
         break
       end

    end

  when "Event Management"
    puts "event management under construction"

  when "[Dev] Populate DB"
    if menu.yes?("Destroy Curent DB and Populate with 200 random Fake players?")
      if menu.yes?("Are you really super dooper sure?") do |q|
        q.default false
        q.positive 'y' #'really super dooper sure'
        q.negative 'No, go back please'
      end

      player_db = {}
      200.times do
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

      else
        puts "Phew! That was close!"
      end
    end


  when "Quit"
    quit = true
  end

end
