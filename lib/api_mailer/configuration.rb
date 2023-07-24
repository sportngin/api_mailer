require 'yaml'
ApiMailer::Configuration = Object.new

ApiMailer::Configuration.instance_eval do
  def filepath
    @filepath ||= Rails.root.join("config/api_mailer.yml")
  end
  def configurations
    @configurations ||= load_config
  end

  def load_config
    if File.exist?(filepath)
      ActiveSupport::HashWithIndifferentAccess.new(load_yaml(ERB.new(File.read(filepath)).result)[Rails.env.to_s])
    else
      raise Exception.new("File not found: config/api_mailer.yml")
    end
  end

  def load_yaml(source)
    # https://bugs.ruby-lang.org/issues/17866
    # https://github.com/rails/rails/commit/179d0a1f474ada02e0030ac3bd062fc653765dbe
    begin
      YAML.load(source, aliases: true)
    rescue ArgumentError
      YAML.load(source)
    end
  end

  def get(name)
    configurations[name.to_s]
  end

  def keys
    configurations.keys
  end
  alias :[] :get
end
