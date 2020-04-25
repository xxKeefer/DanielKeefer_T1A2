require 'text-table'

class Team
  attr_accessor :name, :players, :sr_avg

  def initialize name, players
    @name = name
    @players = players
    @sr_avg = get_sr_avg
  end

  def get_sr_avg
    total_sr = 0
    self.players.each_pair do |role, val|
      val.each { |player| total_sr += player.roles[role]  }
    end
    return total_sr/6
  end

  def print_info
    card = Text::Table.new
    card.head = [self.name, "SR AVG: #{self.sr_avg}"]
    card.rows = []
    self.players.each_pair do |role, val|
      val.each { |player| card.rows.push([role.to_s.capitalize, player.name]) }
    end
    puts card.to_s

  end
end
