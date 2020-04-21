
require "tty-prompt"

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
    self.roles[:preferred] = @@user.select("What is your PREFERRED role?", self.roles[:options])
    self.roles[:second] = @@user.select("If you can't play #{self.roles[:preferred]}, what would you play?", self.roles[:options].reject {|c| c == self.roles[:preferred]})
  end

  def get_sr(role)
    self.roles[role.to_sym] = @@user.ask("What is your skill rating #{role.capitalize}?") do |q|
      q.required true
      q.in("1-5000")
    end
  end

end
