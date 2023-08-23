require 'abstract_controller'
module ApiMailer
  class Base < AbstractController::Base
    abstract!

    include AbstractController::Rendering
    include AbstractController::Logger
    include AbstractController::Helpers
    include AbstractController::Translation
    include AbstractController::AssetPaths
    include AbstractController::Callbacks

    include ActionView::Layouts if defined?(ActionView::Layouts)

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

    def mail(headers={}, &block)
      # Call all the procs (if any)
      default_values = {}
      self.class.default.each do |k,v|
        default_values[k] = v.is_a?(Proc) ? instance_eval(&v) : v
      end

      # Handle defaults
      self.headers = ActiveSupport::HashWithIndifferentAccess.new(default_values.merge(headers)) || {}

      collect_responses(headers, &block)
    end

    def deliver
      if Rails.env.test?
        self.class.test_deliveries << build_message
      else
        deliver_message(build_message)
      end
    end

    def collect_responses(headers)
      if block_given?
        collector = ActionMailer::Collector.new(lookup_context) { render(action_name) }
        yield(collector)
        self.responses = collector.responses
      else
        templates_name = headers.delete(:template_name) || action_name

        each_template(templates_path(headers), templates_name) do |template|
          self.formats = template.formats || [template.format]

          self.responses << {
            body: render(template: template),
            content_type: (template.respond_to?(:type) ? template.type : template.mime_type).to_s
          }
        end
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
        templates.uniq { |t| (t.formats || [t.format])}.each(&block)
      end
    end

    def text_part
      Hashie::Mash.new(responses.select{|part| part[:content_type] == "text/plain"}.first).presence
    end

    def html_part
      Hashie::Mash.new(responses.select{|part| part[:content_type] == "text/html"}.first).presence
    end

    def process(method_name, *args)
      payload = {
        :mailer => self.class.name,
        :action => method_name
      }

      ActiveSupport::Notifications.instrument("process.api_mailer", payload) do
        lookup_context.skip_default_locale! if lookup_context.respond_to?(:skip_default_locale!)

        super
      end
    end
  end
end
