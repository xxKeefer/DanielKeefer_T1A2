require "tty-prompt"
require 'text-table'
require "yaml"
require 'faker'

require_relative "./player.rb"
require_relative "./team.rb"
require_relative "../mod/util.rb"
include Util

class Event
  attr_accessor :name, :date, :players, :player_count, :tank, :damage, :support, :teams, :info

  def initialize players
    @name =""
    @date =""
    @players = players
    @player_count = @players.length
    @tank = []
    @damage = []
    @support = []
    @teams = {}
    @info = {}
    # {
    #   :div => {
    #     :some_name => {
    #       :braket => {
    #         :east => {},
    #         :west => {}
    #       }
    #     }
    #   }
    # }
  end

  def generate_name(type)
    case type.downcase
    when "name"
      "#{Faker::Space.constellation.capitalize}"
    when "div"
      "#{Faker::App.name.capitalize}"
    when "team"
      "#{Faker::Space.moon.capitalize}" +
      "#{Faker::Commerce.color.capitalize}"
    else
      "#{Faker::Address.state.split(/ /).join.capitalize}" +
      "#{Faker::Hipster.word.capitalize}"
    end
  end

  def generate_event
    determine_roles(1, self.players)
    assign_teams
    unassigned_players = self.tank + self.damage + self.support
    determine_roles(2, unassigned_players)
    assign_teams

    print_teams
    puts "Total players left: #{self.tank.length + self.damage.length + self.support.length}"
    self.tank.each { |e| puts "#{e.roles[:preferred]} | #{e.id} | #{e.roles[:second]}"  }
    self.damage.each { |e| puts "#{e.roles[:preferred]} | #{e.id} | #{e.roles[:second]}"  }
    self.support.each { |e| puts "#{e.roles[:preferred]} | #{e.id} | #{e.roles[:second]}"  }
  end

  def print_teams
    self.teams.each_pair { |name, team| team.print_info }
  end

  def determine_roles(pref, player_set)
    self.tank = []
    self.damage = []
    self.support = []
    case pref
    when 1
      pref = :preferred
    when 2
      pref = :second
    else
      pref = :preferred
    end
    if player_set.class == Array
      player_set.each do |v|
        case v.roles[pref]
        when "Tank"
          if self.tank.length<1
            self.tank.push(v)
          end
        when "Damage"
          if self.damage.length<1
            self.damage.push(v)
          end
        when "Support"
          if self.support.length<1
            self.support.push(v)
          end
        else
          self[v.roles.second.downcase.to_sym].push(v)
        end
        puts [self.tank.length, self.damage.length, self.support.length].min
        puts "#{self.tank.length}, #{self.damage.length}, #{self.support.length}"
      end
    else
      player_set.each_pair do |k,v|
        case v.roles[pref]
        when "Tank"
          self.tank.push(v)
        when "Damage"
          self.damage.push(v)
        when "Support"
          self.support.push(v)
        end
      end
    end
  end

  def assign_teams
    smallest_role = [self.tank.length, self.damage.length, self.support.length].min
    while smallest_role>1
      if self.tank.length>1 && self.damage.length>1 && self.support.length>1
        players = {:tank => self.tank.pop(2),
          :damage =>self.damage.pop(2),
          :support => self.support.pop(2)}
      end
      name = generate_name("team")
      self.teams[name.downcase.to_sym] = Team.new(name, players)
      smallest_role -=2
    end
  end


end
