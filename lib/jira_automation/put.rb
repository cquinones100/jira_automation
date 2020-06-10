module JiraAutomation
  class Put < Request
    def initialize(body:, **params)
      @body = body

      super(**params)
    end

    def response
      @response ||= super(url: url) do |uri|
        Net::HTTP::Put.new(uri).tap do |request|
          request.body = body.to_json
          request.set_content_type 'application/json'
        end
      end
    end

    private

    attr_reader :body
  end
end
