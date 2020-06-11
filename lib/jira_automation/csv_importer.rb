require 'csv'

module JiraAutomation
  class CsvImporter
    def initialize(path:)
      @path = path
    end

    def import
      @headers = []
      created_issues = []
      errors = []

      CSV.foreach(path).with_index do |row, index|
        if index.zero?
          row.each do |header|
            next if header.nil?

            @headers << header.downcase
          end

          next
        end

        operation = row[headers.find_index('operation')]

        next if operation.nil?

        params = {
          title: row_value(row, 'ticket name'),
          description: row_value(row, 'description'),
        }
          .tap do |hash|
            project = row_value(row, 'project')

            hash[:project] = project if project
          end
          .tap do |hash|
            assignee = row_value(row, 'assignee')

            hash[:assignee] = assignee if assignee
          end
          .tap do |hash|
            parent = row_value(row, 'parent')

            hash[:parent] = parent if parent
          end
          .tap do |hash|
            estimate = row_value(row, 'estimate')

            hash[:estimate] = estimate if estimate
          end
          .tap do |hash|
            sprint = row_value(row, 'sprint')

            hash[:sprint] = sprint if sprint
          end

        case operation
        when 'create'
          next unless row_value(row, 'key').nil?

          issue = Issue.create(**params)

          if JiraAutomation::Issue === issue
            created_issues << issue

            puts "Created ticket #{created_issue.key}"
          else
            puts "Row #{index + 1} error:"
            puts created_issue
          end
        when 'edit'
          next if row_value(row, 'key').nil?

          issue = Issue.find(key: row_value(row, 'key'))

          issue.update(**params)

          puts "Edited Ticket #{issue.key}"
        when 'delete'
          *args, key = row_value(row, 'ticket link').split('/')

          issue = Issue.find(key: key)

          response = issue.delete

          if response.ok?
            puts "Deleted Ticket #{key}"
          else
          end
        end
      end
    end

    private

    attr_reader :path, :headers

    def row_value(row, header)
      row[header_index(header)] if header_index(header)
    end

    def header_index(header)
      headers.find_index(header)
    end
  end
end