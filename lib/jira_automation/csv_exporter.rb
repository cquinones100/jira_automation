require 'csv'

module JiraAutomation
  class CsvExporter
    def initialize(path:, issues:)
      @path = path
      @issues = build_issues_hash(issues)
    end

    def export
      total_time = 0

      CSV.open(path, 'w') do |csv|
        csv << issues.first[1][:self].values&.keys

        issues.each do |key, issue|
          csv << [issue[:self]&.title] unless issue[:children].size.zero?

          csv << issue[:self].values.values unless issue[:self]&.values.nil?

          total_time += issue[:self]&.estimate.to_i

          issue[:children].each do |child|
            csv << child.values.values unless child.values.nil?

            total_time += child.estimate.to_i
          end
        end

        time_column = issues.first[1][:self].values.keys.find_index(:estimate)

        padding = Array.new(time_column - 1).join(',')

        csv << "#{padding},Total,#{total_time}".split(',')
      end

      puts "Wrote file to #{path}"
    end

    private

    attr_reader :path, :issues

    def build_issues_hash(issues)
      issues.each_with_object({}) do |issue, hash|
        if issue.parent
          hash[issue.parent] ||= { self: nil, children: [] }

          hash[issue.parent][:children] << issue
        else
          hash[issue.key] ||= { self: nil, children: [] }
          hash[issue.key][:self] = issue
        end
      end
    end
  end
end