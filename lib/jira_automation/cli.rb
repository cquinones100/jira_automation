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

    def edit_issue(key, *args)
      Issue.edit_by_key_and_cli_args(key, *args)
    end

    def export_csv(path, project, sprint)
      CsvExporter.new(
        path: path,
        issues: Issue.find_all(project: project, sprint: sprint)
      )
        .export
    end

    def import_csv(path)
      CsvImporter.new(path: path).import
    end

    def total_estimated_time(project, sprint)
      total = Issue.find_all(project: project, sprint: sprint).reduce(0) do |time, issue|
        puts "#{issue.key},#{issue.estimate}"

        time += issue.estimate.to_i
      end

      puts "total: #{total}"
    end

    def total_estimated_time_by_assignee(project, sprint)
      issues = Issue.find_all(project: project, sprint: sprint)

      estimates = issues.each_with_object({}) do |issue, hash|
        assignee = issue.assignee || 'Unassigned'

        hash[assignee] ||= 0

        hash[assignee] += issue.estimate.to_i
      end

      puts 'assignee,total estimate'
      estimates.each do |assignee, estimate|
        puts "#{assignee},#{estimate}"
      end
    end

    def update
      puts `git pull`
      puts `bundle install`
    end

    def update_parent(*args)
      keys, updates = args
    end
  end
end