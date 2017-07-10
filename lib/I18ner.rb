require "I18ner/version"
require "yaml"

module I18ner
  class Base
    attr_reader :yml_file
    attr_reader :items

    def initialize(project)
      @project = "#{project}/config/locales/en.yml"
      @items = []
    end

    def run
      make_keys(content)
      @items.flatten!.sort!
    end

    def content
      YAML.load(File.read(@project))
    end

    def to_s
      @items.each do |m|
        puts m
      end
    end

    private

    def make_keys(data, i = 0, base = nil)
      data.each do |key, value|
        base ||= key
        scope = key

        if value.is_a?(String)
          base_pair = i == 0 ? key : "#{base}.#{key}"
          @items << [ "#{base_pair} => #{value}" ]
        else
          make_keys(value, i+1, i == 0 ? key : "#{base}.#{key}")
        end
      end
    end
  end
end
