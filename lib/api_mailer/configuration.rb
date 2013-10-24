ApiMailer::Configuration = Object.new

ApiMailer::Configuration.instance_eval do
  def filepath
    @filepath ||= Rails.root.join("config/api_mailer.yml")
  end
  def configurations
    @configurations ||=
  end

  def load_config
    if File.exists?(filepath)
      ActiveSupport::HashWithIndifferentAccess.new(YAML.load(ERB.new(File.read(filepath)).result)[Rails.env.to_s])
    else
      raise Exception.new("File not found: config/api_mailer.yml")
    end
  end
  private :load_config

  def get(name)
    configurations[name.to_s]
  end

  def keys
    configurations.keys
  end
  alias :[] :get
end
