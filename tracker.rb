require 'net/http'

class Tracker
  def self.get_response
    url = URI("https://api.github.com/repos/rails/rails/pulls")

    https = Net::HTTP.new(url.host, url.port)
    https.use_ssl = true

    request = Net::HTTP::Get.new(url)

    response = https.request(request)
    response.read_body
  end
end

