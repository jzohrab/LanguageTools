# Reads a yml file and exposes settings.

require 'yaml'

class Settings

  def initialize(fname)
    @fname = fname
    @yml = YAML.load_file(fname)
  end

  def ankiconnect
    @yml['ankiconnect']
  end

  def media_file
    @yml['ankimediafolder']
  end

  def deck(language)
    n = @yml['languages'][language]
    raise "Missing #{language} in settings/languages." if n.nil?
    n['deck']
  end

  def voice(language)
    n = @yml['languages'][language]
    raise "Missing #{language} in settings/languages." if n.nil?
    n['voice']
  end

end
