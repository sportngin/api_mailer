require 'abstract_controller'
module ApiMailer
  class Base < AbstractController::Base
    abstract!

    include AbstractController::Rendering

    attr_accessor :action_name
    attr_accessor :responses
    attr_accessor :headers

    private_class_method :new

    self.view_paths = ["app/views", "app/views/mailers"]

    def self.method_missing(method_name, *args)
      if respond_to?(method_name)
        new(method_name, *args)
      else
        super
      end
    end

    def self.test_deliveries
      @test_deliveries ||= []
    end

    def self.respond_to?(method, include_private = false)
      super || action_methods.include?(method.to_s)
    end

    class_attribute :default_params
    self.default_params = {}.freeze
    def self.default(value = nil)
      self.default_params = default_params.merge(value).freeze if value
      default_params
    end

    def initialize(action_name, *args)
      self.action_name = action_name
      self.responses = []
      process(action_name, *args)
    end

    def mail(headers={})
      # Call all the procs (if any)
      default_values = {}
      self.class.default.each do |k,v|
        default_values[k] = v.is_a?(Proc) ? instance_eval(&v) : v
      end

      # Handle defaults
      self.headers = ActiveSupport::HashWithIndifferentAccess.new(headers.reverse_merge(default_values))

      collect_responses(headers)
    end

    def deliver
      if Rails.env.test?
        self.class.test_deliveries << build_message
      else
        deliver_message(build_message)
      end
    end

    def collect_responses(headers)
      templates_name = headers.delete(:template_name) || action_name

      each_template(templates_path(headers), templates_name) do |template|
        self.formats = template.formats

        self.responses << {
          body: render(template: template),
          content_type: template.type.to_s
        }
      end
    end

    def templates_path(headers)
      [headers.delete(:template_path) || self.class.name.underscore]
    end

    def each_template(paths, name, &block)
      templates = lookup_context.find_all(name, paths)
      if templates.empty?
        raise ActionView::MissingTemplate.new(paths, name, paths, false, 'mailer')
      else
        templates.uniq { |t| t.formats }.each(&block)
      end
    end


    [:html_part, :text_part].each do |part|
      define_method part do
        Hashie::Mash.new(responses.select{|part| part[:content_type] == "text/html"}.first).presence
      end
    end

    def process(method_name, *args)
      payload = {
        :mailer => self.class.name,
        :action => method_name
      }

      ActiveSupport::Notifications.instrument("process.api_mailer", payload) do
        lookup_context.skip_default_locale!

        super
      end
    end
  end
end
