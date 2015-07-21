module NightTrain
  VERSION = File.read(File.expand_path('../../../VERSION', __FILE__))

  def self.version_string
    "NightTrain version #{NightTrain::VERSION}"
  end
end
