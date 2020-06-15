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
      threads = []
      tickets = []

      start = Time.now

      CSV.foreach(path).with_index do |row, index|
        row = row
        if index.zero?
          row.each do |header|
            next if header.nil?

            @headers << header.downcase
          end

          next
        end

        threads << Thread.new do
          header_index = headers.find_index('operation')

          next if header_index.nil?

          operation = row[header_index]

          next if operation.nil?

          params = {}
            .tap do |hash|
              title = row_value(row, 'title')
              description = row_value(row, 'description')

              hash[:title] = title if title
              hash[:description] = description if description
            end
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
              sprint_field_name = SPRINT_FIELD_NAME || row_value(row, 'sprint field name')

              hash[:sprint] = sprint if sprint
              hash[:sprint_field_name] = sprint_field_name if sprint_field_name
            end

          next if operation.nil?

          case operation
          when 'create'
            next unless row_value(row, 'key').nil?

            issue = Issue.create(**params)

            if JiraAutomation::Issue === issue
              created_issues << issue

              puts "Created ticket #{issue.key} #{issue.link}"
            else
              puts "Row #{index + 1} error:"
              puts issue
            end
          when 'edit'
            next if row_value(row, 'key').nil?

            issue = Issue.find(key: row_value(row, 'key'))

            response = issue.update(**params)

            if Issue === response
              puts "Edited Ticket #{issue.key} #{issue.link}"
            else
              puts "Row #{index + 1} error:"
              puts response
            end
          when 'delete'
            *args, key = row_value(row, 'key') || row_value(row, 'ticket link')&.split('/')

            issue = Issue.find(key: key)

            next if issue.nil?

            response = issue.delete

            if Issue === response
              puts "Deleted Ticket #{key}"
            else
              puts "Row #{index + 1} error:"
              puts response
            end
          end

          tickets << nil
        end
      end

      threads.each(&:join)

      puts "Touched #{tickets.size} tickets in #{Time.now - start} seconds"
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