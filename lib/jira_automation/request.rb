module JiraAutomation
  class Request
    def initialize(url:)
      @url = url
    end

    def response(url:)
      uri = URI(BASE_URL + url)

      resp = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
        request = yield(uri)

        request.basic_auth(*TOKEN.split(':'))
      
        http.request(request)
      end
    
      {
        status: resp.code,
        body: resp.body
      }
    end

    def response_body
      JSON.parse(response[:body])
    end

    def status
      JSON.parse(response[:status])
    end

    def ok?
      status.to_s.start_with? '2'
    end

    private

    attr_reader :url
  end
end