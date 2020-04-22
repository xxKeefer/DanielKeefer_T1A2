require "tty-prompt"
require "yaml"
require 'faker'

require_relative "./classes/player.rb"
require_relative "./classes/event.rb"
require_relative "./mod/util.rb"
include Util

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
    Util.initialize_db("player")
    while true

       case menu.select("Player Management Menu",
         ["Create / Edit Player",
           "Search for Player",
            "Display All Players",
            "Back to Main Menu"])

       when "Create / Edit Player"
         player_db = Util.load_db("player")
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
    Util.initialize_db("event")
    while true
      case menu.select("Event Management Menu",
        ["Create Event",
          "View Archive",
          "Back to Main Menu"])
      when "Create Event"
        new_event = Event.new(Util.load_db("player"))
        new_event.generate_event
      when "View Archive"
        p "temp"

      else
        break
      end
    end


  when "[Dev] Populate DB"
    if menu.yes?("Destroy Curent DB and Populate with random Fake players?")
      if menu.yes?("Are you really super dooper sure?") do |q|
        q.default false
        q.positive 'y' #'really super dooper sure'
        q.negative 'No, go back please'
      end

        number_of_fakes = menu.ask("How many FAKE PLAYERS? 1 - 1000") do |q|
          q.in("1-1000")
        end
        Util.populate(number_of_fakes.to_i)

      else
        puts "Phew! That was close!"
      end
    end


  when "Quit"
    quit = true
  end

end
