require "tty-prompt"
require 'text-table'
require "yaml"
require 'faker'

require_relative "./player.rb"
require_relative "./team.rb"
require_relative "./div.rb"
require_relative "../mod/util.rb"
include Util

class Event
  attr_accessor :name, :date, :players, :player_count, :teams, :info

  def initialize players
    @name = generate_name('name')
    @date = Time.new.strftime("%d_%m_%Y")
    @players = players
    @unassigned = @players.values.shuffle
    @player_count = @players.length
    @teams = {}
    @info = []
    @completed = false

  end

  def generate_name(type)
    case type.downcase
    when "name"
      "#{Faker::Space.constellation.capitalize}"
    when "div"
      "#{Faker::Address.state.split(/ /).join.capitalize}" +
      "#{Faker::Hipster.word.capitalize}"
    when "team"
      "#{Faker::Space.moon.capitalize}" +
      "#{Faker::Commerce.color.split(/ /).first.capitalize}"
    end
  end

  def generate_event
    puts "Please be patient, this may take a while depending on amount of players."
    fix_teams
    generate_divisions
    #print_divisions
  end

  def print_teams
    @teams.each_pair { |name, team| team.print_info }
    @unassigned.each { |e| puts "#{e.roles[:preferred]} | #{e.roles[:second]} | #{e.name}" }
  end

  def determine_roles
    preference = :preferred
    lobby = 0
    new_team = {
      :tank => [],
      :damage => [],
      :support => []
    }
    looked_at = []
    considered_twice = false
    players_left = @unassigned.length

      while true
        if lobby == 6
          name = generate_name("team")
          self.teams[name.downcase.to_sym] = Team.new(name, new_team)
          lobby = 0
          new_team = {
            :tank => [],
            :damage => [],
            :support => []
          }
        elsif considered_twice && preference != :second
          preference = :second
          looked_at = []
          considered_twice = false
        elsif considered_twice && preference == :second || @unassigned.empty?
          new_team.values.each { |e| @unassigned += e }
          break
        else
          case @unassigned[0].roles[preference].downcase
          when "tank"
            if new_team[:tank].length<2
              lobby += 1
              new_team[:tank].push(@unassigned.slice!(0))
            else
              if looked_at.count(@unassigned[0])>4
                considered_twice = true
              else
                looked_at.push(@unassigned[0])
                @unassigned.push(@unassigned.slice!(0))
              end
            end
          when "damage"
            if new_team[:damage].length<2
              lobby += 1
              new_team[:damage].push(@unassigned.slice!(0))
            else
              if looked_at.count(@unassigned[0])>4
                considered_twice = true
              else
                looked_at.push(@unassigned[0])
                @unassigned.push(@unassigned.slice!(0))
              end
            end
          when "support"
            if new_team[:support].length<2
              lobby += 1
              new_team[:support].push(@unassigned.slice!(0))
            else
              if looked_at.count(@unassigned[0])>4
                considered_twice = true
              else
                looked_at.push(@unassigned[0])
                @unassigned.push(@unassigned.slice!(0))
              end
            end
          end
        end
      end
  end

  def fix_teams

    until @unassigned.empty?
      @unassigned = @players.values.shuffle
      @teams = {}
      determine_roles
    end
  end

  def generate_div_size
    puts "Total players: #{self.player_count}"
    puts "expected teams in perfect situation: #{self.player_count/6}"
    puts "Amount of teams = #{self.teams.length}"
    puts "even amount of teams?"
    if self.teams.length.modulo(2) == 0
      forced_even = self.teams.length
      p "yes"
    else
      forced_even = self.teams.length-1
      p "no, there will be #{self.teams.length - forced_even} orphaned teams"
    end

    division_size = 8
    while division_size<forced_even && forced_even.modulo(division_size) != 0
      division_size = division_size+2
    end
    division_size<forced_even ? (p "#{forced_even/division_size} Divisions of #{division_size} Teams") : (p "1 Division of #{division_size} Teams (open div)")
  end

  def generate_divisions
    sorted = @teams.values.sort_by(&:sr_avg)
    sorted.each_slice(8) do |teams|
      @info.push(Division.new(generate_name('div'), teams))
    end
  end

  def print_divisions
    @info.each(&:print_info)
  end

  def save_event


  end


end
