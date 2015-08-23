module MessageTrain
  VERSION = File.read(File.expand_path('../../../VERSION', __FILE__))

  def self.version_string
    "MessageTrain version #{MessageTrain::VERSION}"
  end
end
