module NightTrain
  def self.configure(configuration = NightTrain::Configuration.new)
    if block_given?
      yield configuration
    end
    @@configuration = configuration
  end

  def self.configuration
    @@configuration ||= NightTrain::Configuration.new
  end

  class Configuration
    attr_accessor :friendly_id_tables, :name_columns

    def initialize
      self.friendly_id_tables = []
      self.name_columns = {}
    end

  end
end