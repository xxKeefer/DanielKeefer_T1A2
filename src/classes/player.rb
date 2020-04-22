
require "tty-prompt"
require 'text-table'

class Player
  @@user = TTY::Prompt.new
  attr_accessor :id, :name, :roles, :dossier, :history
  def initialize
    @id = ""
    @name = ""
    @roles = {
      :options => ["Tank","Damage","Support"],
      :preferred => nil,
      :second => nil,
      :tank => 0,
      :damage => 0,
      :support => 0
    }
    @dossier = {
      :endorsed =>{
        :punctual => 0,
        :high_skill => 0,
        :positive => 0
      },
      :reported => {
        :forfeits => 0,
        :low_skill => 0,
        :toxicity => 0
      }
    }
    @history = {}
  end

  def registration
    get_id
    get_name
    get_role_pref
    get_sr("tank")
    get_sr("damage")
    get_sr("support")
  end

  def get_id
    self.id = @@user.ask ("What is your battle.net name?") do |q|
      q.required true
      q.validate /\A[\w\d]{1,15}#\d{4,5}\Z/
    end
  end

  def get_name
    self.name = @@user.ask ("What do people call you in game?") do |q|
      q.required true
      q.validate /\A[\w\d]{1,15}\Z/
    end
  end

  def get_role_pref
    self.roles[:preferred] = @@user.select(
      "What is your PREFERRED role?",
       self.roles[:options])
    self.roles[:second] = @@user.select(
      "If you can't play #{self.roles[:preferred]}, what would you play?",
       self.roles[:options].reject {|c| c == self.roles[:preferred]})
  end

  def get_sr(role)
    self.roles[role.to_sym] = @@user.ask("What is your skill rating #{role.capitalize}?") do |q|
      q.required true
      q.in("1-5000")
    end
  end

  def update_dossier
    choices = self.dossier[:endorsed].keys + self.dossier[:reported].keys
    updates = @@user.multi_select("Endorse / Report #{self.name} for:", choices)
    for v in updates
      if self.dossier[:endorsed].has_key?(v)
        self.dossier[:endorsed][v]+=1
      elsif self.dossier[:reported].has_key?(v)
        self.dossier[:reported][v]+=1
      end
      puts "#{self.name}'s Dossier Updated!'"
    end
  end

  def print_info
    summary = Text::Table.new
    summary.head = ["Player Card", self.id, "AKA: #{self.name}"]
    summary.rows =[]
    roles_arr = ["Tank: #{self.roles[:tank]}SR",
      "Damage: #{self.roles[:damage]}SR",
      "Support: #{self.roles[:support]}SR"]

    case self.roles[:preferred]
    when "Tank"
      roles_arr[0]= "♥ " + roles_arr[0]
    when "Damage"
      roles_arr[1]= "♥ " + roles_arr[1]
    when "Support"
      roles_arr[2]= "♥ " + roles_arr[2]
    end

    case self.roles[:second]
    when "Tank"
      roles_arr[0]= "• " + roles_arr[0]
    when "Damage"
      roles_arr[1]= "• " + roles_arr[1]
    when "Support"
      roles_arr[2]= "• " + roles_arr[2]
    end
    summary.rows.push(roles_arr)
    summary.foot = ["Symbol Meaning", "♥ - Preferred Role", "• - Second Pick"]
    summary.align_column(2,:center)
    puts summary.to_s
    endorse = Text::Table.new
    endorse.rows = []
    endorse.rows.push(["[COMENDATIONS]", "="*15, "Singles", "Tens"])
    endorse.rows.push(["Total: #{self.dossier[:endorsed][:punctual]}",
      "Punctuality",
      "• "*self.dossier[:endorsed][:punctual].modulo(5),
      "• "*(self.dossier[:endorsed][:punctual]/5)])
    endorse.rows.push(["Total: #{self.dossier[:endorsed][:high_skill]}",
      "High Skill",
      "• "*self.dossier[:endorsed][:high_skill].modulo(5),
      "• "*(self.dossier[:endorsed][:high_skill]/5)])
    endorse.rows.push(["Total: #{self.dossier[:endorsed][:positivity]}",
      "Positivity",
      "• "*self.dossier[:endorsed][:positive].modulo(5),
      "• "*(self.dossier[:endorsed][:positive]/5)])

    endorse.rows.push(["[REPORTED FOR]", "="*15, "Singles", "Tens"])
    endorse.rows.push(["Total: #{self.dossier[:reported][:forfeits]}",
      "Forfeits",
      "• "*self.dossier[:reported][:forfeits].modulo(5),
      "• "*(self.dossier[:reported][:forfeits]/10)])
    endorse.rows.push(["Total: #{self.dossier[:reported][:low_skill]}",
      "Low Skill",
      "• "*self.dossier[:reported][:low_skill].modulo(5),
      "• "*(self.dossier[:reported][:low_skill]/10)])
    endorse.rows.push(["Total: #{self.dossier[:reported][:toxicity]}",
      "Toxicity",
      "• "*self.dossier[:reported][:toxicity].modulo(5),
      "• "*(self.dossier[:reported][:toxicity]/10)])

  endorse.align_column(1, :right)
  endorse.align_column(2, :center)
  endorse.align_column(3, :left)
  endorse.align_column(4, :left)
  puts endorse.to_s
  puts "#"*90

  end

end
