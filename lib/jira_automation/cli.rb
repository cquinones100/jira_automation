module JiraAutomation
  class CLI
    def initialize(raw_args)
      @raw_args = raw_args
    end

    def start
      command, *args = raw_args

      send(command, *args)
    end

    private

    attr_reader :raw_args

    def import_csv(path)
      CsvImporter.new(path: path).import
    end

    def update_tickets(*args)
      keys, updates = args
    end

    def update_parent(*args)
      keys, updates = args
    end
  end
end