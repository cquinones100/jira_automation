module JiraAutomation
  class Delete < Request
    def response
      @response ||= super(url: url) { |uri| Net::HTTP::Delete.new(uri) }
    end
  end
end