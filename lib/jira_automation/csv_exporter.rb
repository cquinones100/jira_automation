require 'csv'

module JiraAutomation
  class CsvExporter
    def initialize(path:, issues:)
      @path = path
      @issues = issues
    end

    def export
      CSV.open(path, 'w') do |csv|
        csv << issues.first.values.keys

        issues.sort_by(&:key).each { |issue| csv << issue.values.values unless issue.values.nil? }
      end

      puts "Wrote file to #{path}"
    end

    private

    attr_reader :path, :issues
  end
end