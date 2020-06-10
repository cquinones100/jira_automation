module JiraAutomation
  class Get < Request
    def response
      @response ||= super(url: url) { |uri| Net::HTTP::Get.new(uri) }
    end
  end
end