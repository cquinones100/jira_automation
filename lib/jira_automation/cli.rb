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

    def update
      puts `git pull`
      puts `bundle install`
    end

    def import_csv(path)
      CsvImporter.new(path: path).import
    end

    def export_csv(path, project, sprint)
      CsvExporter.new(
        path: path,
        issues: Issue.find_all(project: project, sprint: sprint)
      )
        .export
    end

    def total_estimated_time(project, sprint)
      total = Issue.find_all(project: project, sprint: sprint).reduce(0) do |time, issue|
        puts "#{issue.key},#{issue.estimate}"

        time += issue.estimate.to_i
      end

      puts "total: #{total}"
    end

    def update_tickets(*args)
      keys, updates = args
    end

    def update_parent(*args)
      keys, updates = args
    end
  end
end