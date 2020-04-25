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

  def print_matches
    return unless @teams.length == 8
    stu = '─'
    std = '│'
    tel = '├'
    upl = '┘'
    dwl = '┐'
    ter = '┤'
    upr = '└'
    dwr = '┌'
    # swd = '⚔️'
    spc = ' '
    r1 = stu + dwl + spc * 6 + dwr + stu
    r2 = spc + tel + stu + dwl + spc * 2 + dwr + stu + ter + spc
    r3 = stu + upl + spc + std + spc * 2 + std + spc + upr + stu
    r4 = spc * 3 + tel + stu * 2 + ter + spc * 3
    r5 = stu + dwl + spc + std + spc * 2 + std + spc + dwr + stu
    r6 = spc + tel + stu + upl + spc * 2 + upr + stu + ter + spc
    r7 = stu + upl + spc * 6 + upr + stu
    card = Text::Table.new
    card.head = ["EAST","MATCH UP", "WEST"]
    card.rows = [
      [@teams[0].name, r1, @teams[1].name],
      ['', r2, ''],
      [@teams[2].name, r3, @teams[3].name],
      ['', r4, ''],
      [@teams[4].name, r5, @teams[5].name],
      ['', r6, ''],
      [@teams[6].name, r7, @teams[7].name]
    ]
    card.align_column(1, :right)
    puts card.to_s
  end

  def print_teams
    @teams.each do |e|
      puts "----| TEAM #{@teams.index(e) + 1} |----"
      puts e.print_info
    end
  end

end
