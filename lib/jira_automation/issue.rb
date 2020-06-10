module JiraAutomation
  class Issue
    class << self
      def find(key:)
        require 'pry'
        binding.pry

        new(data: Get.new(url: '/issue/' + key).response_body)
      end

      def create(
        title:,
        description:,
        project: DEFAULT_PROJECT,
        parent: nil,
        estimate: nil,
        team: nil,
        assignee: nil
      )
        post_body = {
          'fields': {
            'project': { 'key': project },
            'summary': title,
            'description': {
              "version": 1,
              "type": 'doc',
              "content": [
                {
                  "type": 'paragraph',
                  "content": [
                    {
                      "type": 'text',
                      "text": description
                    }
                  ]
                }
              ]
            },
            'issuetype': { 'name': 'Task' }
          }
        }
          .then do |hash|
            if estimate
              hash[:fields].merge!('timetracking': { 'originalEstimate': estimate })
            end

            hash
          end
          .then do |hash|
            user = team&.find { |user| user[:username] == assignee }

            assignee_id = user && user[:accountId]

            hash[:fields].merge!('assignee': { 'id': assignee_id }) if assignee_id

            hash
          end

        response = Post.new(url: '/issue', body: post_body)

        if response.ok?
          find(key: response.response_body['key']) 
        else
          response.response_body
        end
      end
    end

    attr_reader :data

    def initialize(data:)
      @data = data
    end
  end
end