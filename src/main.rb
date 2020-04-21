require "tty-prompt"
require "yaml"

require_relative "./classes/player.rb"

menu = TTY::Prompt.new

puts `clear`

quit = false
until quit
  case menu.select("Welcome to Overwatch Event Planner!",
     ["Player Management",
       "Event Management",
       "Quit"])

  when "Player Management"
    if !(File.exists?("./db/players.yml"))
      player_db = File.new("./db/players.yml", "w")
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
         # #creat player function
         player_db = YAML.load(File.read("./db/players.yml"))
         new_user = Player.new()
         new_user.registration
         if player_db.has_key?(new_user.id)
           if menu.yes?("Player #{new_user.id} already exist, overide information?")
             player_db["#{new_user.id}"] = new_user
             File.write("./db/players.yml", YAML.dump(player_db))
             puts "#{new_user.id}'s Info Updated!"
           else
             puts "Player Data Discarded."
           end
         else
           player_db["#{new_user.id}"] = new_user
           File.write("./db/players.yml", YAML.dump(player_db))
           puts "Database updated!"
         end




       when "Search for Player"
         #search_player function
       when "Display All Players"
         #print player to screen
       else
         break
       end

    end

  when "Event Management"
    puts "event management under construction"

  when "Quit"
    quit = true
  end

end
