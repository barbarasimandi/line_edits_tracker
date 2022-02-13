require 'net/http'
require 'json'

class Tracker
  def self.get_pull_requests
    pull_requests = get_json("https://api.github.com/repos/rails/rails/pulls?per_page=5")

    pull_requests.inject([]) do |prs, pull_request|
      url = pull_request.fetch("url")
      prs << get_json(url)
    end
  end

  private

  def self.get_json(url)
    uri = URI(url)
    https = Net::HTTP.new(uri.host, uri.port)
    https.use_ssl = true
    request = Net::HTTP::Get.new(uri)
    response = https.request(request)
    JSON.parse(response.read_body)
  end
end
