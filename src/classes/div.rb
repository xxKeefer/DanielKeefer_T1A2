require 'text-table'

class Division
  attr_accessor :name, :teams, :sr_avg

  def initialize(name, teams)
    @name = name
    @teams = teams
    @sr_avg = get_sr_avg
  end

  def get_sr_avg
    total_sr = 0
    @teams.each { |e| total_sr += e.sr_avg }
    total_sr / @teams.length
  end

  def print_info
    card = Text::Table.new
    card.head = ["#{@name} Division", "SR AVG: #{@sr_avg}"]
    card.rows = []
    @teams.each do |team|
      card.rows.push([team.name, team.sr_avg])
    end
    puts card.to_s

  end
end
