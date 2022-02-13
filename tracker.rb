require 'net/http'
require 'json'

require 'byebug'

class Tracker

  BEARER_TOKEN = File.read('.bearer').chomp
  BASE_URL = "https://api.github.com/repos/rails/rails/pulls"

  def self.get_pull_requests
    #TODO recursively read pages
    pull_requests = get_json("#{BASE_URL}?per_page=15")

    prs_with_multiple_commits = {}

    pull_requests.map do |pull_request|
      url = pull_request[:url]

      pr = get_json(url)
      pr_number = pr[:number]

      prs_with_multiple_commits[pr_number] = collect_commits(pr_number) if pr[:commits] > 1
      prs_with_multiple_commits
    end
  end

  def self.collect_commits(pr_number)
    commits = get_json("#{BASE_URL}/#{pr_number}/commits")
    commits.map { |commit| commit[:sha] }
  end

  private

  def self.get_json(url)
    uri = URI(url)
    https = Net::HTTP.new(uri.host, uri.port)
    https.use_ssl = true
    request = Net::HTTP::Get.new(uri)
    request["Authorization"] = BEARER_TOKEN
    response = https.request(request)
    JSON.parse(response.read_body, symbolize_names: true)
  end
end
