require 'net/http'
require 'json'

class Tracker
  def self.get_response
    url = URI("https://api.github.com/repos/rails/rails/pulls?per_page=5")

    https = Net::HTTP.new(url.host, url.port)
    https.use_ssl = true

    request = Net::HTTP::Get.new(url)

    response = https.request(request)

    pull_requests = JSON.parse(response.read_body)

    prs = []

    pull_requests.each do |pull_request|
      url = pull_request.fetch("url")
      request = Net::HTTP::Get.new(url)

      response = https.request(request)

      prs << JSON.parse(response.read_body)
    end
  end
end
