module JiraAutomation
  class Issue
    class << self
      def find(key:)
        issue = new(data: Get.new(url: '/issue/' + key).response_body)

        return unless issue.valid?

        issue
      end

      def find_all(project:, sprint:)
        jql = "project = '#{project}' AND sprint = '#{sprint}'"

        start_at = -1
        results = []
        total_results = nil
        response = Post.new(url: '/search', body: { jql: jql, startAt: start_at }).response_body
        issues = response['issues']

        until issues.size.zero?
          issues.each { |issue| results << issue }
          start_at = results.size + 1
          response = Post.new(url: '/search', body: { jql: jql, startAt: start_at }).response_body
          issues = response['issues']
        end

        return_issues = []
        threads = []

        results.each do |data|
          threads << Thread.new { return_issues << Issue.find(key: Issue.new(data: data).key) }
        end

        threads.each(&:join)

        return_issues
      end

      def create(**params)
        response = Post.new(url: '/issue', body: post_params(**params))

        if response.ok?
          find(key: response.response_body['key']) 
        else
          response.response_body
        end
      end

      def post_params(
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
              hash[:fields].merge!('timetracking': { 'originalEstimate': estimate + 'h' })
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
      end

      def put_params(
        title: nil,
        description: nil,
        project: JiraAutomation::DEFAULT_PROJECT,
        parent: nil,
        estimate: nil,
        team: JiraAutomation::DEFAULT_TEAM,
        assignee: nil,
        sprint: nil,
        issue_type: nil
      )
        { update: {} }.tap do |hash|
          if estimate
            hash[:update].merge!(
              timetracking: [ edit: { originalEstimate: estimate + 'h' } ]
            )
          end

          hash[:update].merge!(summary: [ set: title ]) if title
        end
      end
    end
    
    attr_reader :data

    def initialize(data:)
      @data = data
    end

    def valid?
      !data.keys.include?('errorMessages') && !data.keys.include?('errors')
    end

    def update(**params)
      response = Put.new(url: '/issue/' + key, body: self.class.put_params(**params))

      if response.ok?
        self.class.find(key: key)
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

    def delete
      response = Delete.new(url: '/issue/' + key)

      response
    end

    def properties
      values.keys
    end

    def values
      return nil unless fields

      {
        :key => key,
        :link => BASE_URL.gsub('/rest/api/3', '') + 'browse/' + key,
        'ticket name' => fields.dig('summary'),
        :description => description,
        :assignee => fields.dig('assignee', 'displayName'),
        :estimate => estimate,
        :parent => fields.dig('parent', 'key'),
        :reporter => fields.dig('creator', 'displayName'),
        :project => fields.dig('project', 'key')
      }
    end

    def fields
      data['fields']
    end
    
    def description
      (data.dig('fields', 'description', 'content') || []).select do |content|
        content['type'] == 'paragraph'
      end
        .map do |paragraph|
          paragraph['content'].select do |paragraph_content|
            paragraph_content['type'] == 'text'
          end
            .map { |paragraph_content| paragraph_content['text'] || '' }
        end
            .join("\n")
    end

    def estimate
      string = fields.dig('timetracking', 'originalEstimate')
      return if string.nil?

      components = string.split(' ')
      estimate_map = {
        'h' => 1,
        'd' => 8,
        'm' => 240
      }

      components.reduce(0) do |acc, component|
        value = /\d+/.match(component).send(:[], 0)&.to_i
        unit = /[a-z]+/.match(component).send(:[], 0)

        acc += value * (estimate_map[unit])
      end
    end
  end
end