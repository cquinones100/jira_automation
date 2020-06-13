module JiraAutomation
  class Project
    def initialize(data:)
      @data = data
    end

    def key
      data['key']
    end

    private

    attr_reader :data
  end
end