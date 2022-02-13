require 'net/http'
require 'json'

class Tracker

  BEARER_TOKEN = File.read('.bearer').chomp
  PULL_REQUESTS_BASE_URL = "https://api.github.com/repos/rails/rails/pulls"

  def self.print
    data = get_pull_requests_with_duplicates
    data.each_pair do |pr_number, file_links|
      p "In https://github.com/rails/rails/pull/#{pr_number} the following files have been modified in multiple commits: #{file_links.join(', ')}"
    end
  end

  # [{pr1_number => ["link_to_file2_path"]}, {pr2_number => ["link_to_file3_path", "link_to_file4_path"]}]
  def self.get_pull_requests_with_duplicates
    #TODO recursively read pages
    pull_requests = get_json("#{PULL_REQUESTS_BASE_URL}?per_page=100")

    prs_commits_files = {}
    pull_requests.map do |pull_request|
      pr = get_json(pull_request[:url])
      pr_number = pr[:number]
      prs_commits_files[pr_number] = collect_files(pr_number) if pr[:commits] > 1
    end

    prs_commits_files.reject!{|_pr_number, file_links| file_links.empty?}
  end

  # pr1_number
  # ["link_to_file2_path"]
  def self.collect_files(pr_number)
    prs_commits_files = { pr_number => []}
    commits = get_json("#{PULL_REQUESTS_BASE_URL}/#{pr_number}/commits")
    commit_urls = commits.map { |commit| commit[:url] }

    commit_urls.each do |commit_url|
      prs_commits_files[pr_number] << get_json(commit_url)[:files].map{|f| f[:filename]}
    end

    check_duplicates(prs_commits_files)
  end

  # {pr1_number => [["file1_path", "file2_path"], ["file2_path"]]}
  # ["link_to_file2_path"]
  def self.check_duplicates(prs_commits_files)
    duplicates = []
    prs_commits_files.each do |_pr_number, commit_url_files|
      intersection = commit_url_files.inject { |acc, file| acc & file }
      duplicates += intersection if intersection.any?
    end

    duplicates.map{ |file| "https://github.com/rails/rails/blob/main/#{file}" }
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
