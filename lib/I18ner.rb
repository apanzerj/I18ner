require "I18ner/version"
require "yaml"
module I18ner
  class Base
    attr_reader :yml_file
    attr_reader :items

    def initialize(project)
      @project = "#{project}/config/locales/en.yml"
      puts @project
      puts project
      @items = []
    end

    def run
      make_keys(YAML.load(File.read(@project)))
      @items.flatten!.sort!
    end

    private

    def make_keys(data, i = 0, base = nil)
      data.each do |key, value|
        base ||= key
        scope = key

        if value.is_a?(String)
          if i==0
            @items << [key]
            puts "#{key} => #{value}"
          else
            @items << ["#{base}.#{key}"]
            puts "#{base}.#{key} => #{value}" if i != 0
          end
        elsif value.is_a?(Hash)
          new_base = i==0 ? base : base+".#{key}"
          make_keys(value, i+1, new_base)
        end
      end
    end
  end
end
