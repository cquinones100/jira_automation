module JiraAutomation
  class Issue
    class << self
      def find(key:)
        new(data: Get.new(url: '/issue/' + key).response_body)
      end

      def create(
        title:,
        description: nil,
        project: JiraAutomation::DEFAULT_PROJECT,
        parent: nil,
        estimate: nil,
        team: JiraAutomation::DEFAULT_TEAM,
        assignee: nil,
        sprint: nil,
        issue_type: nil
      )
        post_body = {
          'fields': {
            'project': { 'key': project },
            'summary': title,
            'issuetype': { 'name': 'Task' },
          }
        }
          .tap do |hash|
            if description
              hash[:fields].merge!(
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
                }
              )
            end
          end
          .tap do |hash|
            if estimate
              hash[:fields].merge!('timetracking': { 'originalEstimate': estimate })
            end
          end
          .tap do |hash|
            user = team&.find { |user| user['username'] == assignee }

            assignee_id = user && user['accountId']

            hash[:fields].merge!('assignee': { 'id': assignee_id }) if assignee_id
          end
          .tap do |hash|
            hash[:fields].merge!('issuetype': { 'name': issue_type }) if issue_type
          end
          .tap do |hash|
            hash[:fields].merge!('parent': { 'key': parent }) if parent
            hash[:fields].merge!('issuetype': { 'name': 'Sub-task' }) if parent
          end
          .tap do |hash|
            hash[:fields].merge!('sprint': { 'id': sprint }) if sprint
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

    def update(
        title:,
        description: nil,
        project: JiraAutomation::DEFAULT_PROJECT,
        parent: nil,
        estimate: nil,
        team: JiraAutomation::DEFAULT_TEAM,
        assignee: nil,
        sprint: nil,
        issue_type: nil
    )
      post_body = {
        'fields': {
          'project': { 'key': project },
          'summary': title,
          'issuetype': { 'name': 'Task' },
        }
      }
        .tap do |hash|
          if description
            hash[:fields].merge!(
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
              }
            )
          end
        end
        .tap do |hash|
          if estimate
            hash[:fields].merge!('timetracking': { 'originalEstimate': estimate })
          end
        end
        .tap do |hash|
          user = team&.find { |user| user['username'] == assignee }

          assignee_id = user && user['accountId']

          hash[:fields].merge!('assignee': { 'id': assignee_id }) if assignee_id
        end
        .tap do |hash|
          hash[:fields].merge!('issuetype': { 'name': issue_type }) if issue_type
        end
        .tap do |hash|
          hash[:fields].merge!('parent': { 'key': parent }) if parent
          hash[:fields].merge!('issuetype': { 'name': 'Sub-task' }) if parent
        end


      response = Put.new(url: '/issue/' + key, body: post_body)

      if response.ok?
        find(key: response.response_body['key']) 
      else
        response.response_body
      end
    end

    def assign_user(team: JiraAutomation::DEFAULT_TEAM, assignee:)
      user = team&.find { |user| user['username'] == assignee }

      assignee_id = user && user['accountId']

      put_body = { 'fields': { 'assignee': { 'id': assignee_id } } }

      response = Put.new(url: '/issue/' + key, body: put_body).response
    end

    def key
      data['key']
    end
  end
end