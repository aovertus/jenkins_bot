require "octokit"

class GithubClient
  def initialize(sha)
    @client = Octokit::Client.new(
                access_token: "access_token" # Generate an access token for you user/app
              )
    @sha = sha
  end

  def commit_author
    @commit_author ||= commit_info[:commit][:author][:name]
  end

  def commit_url
    @commit_url ||= commit_info[:html_url]
  end

  private

  def commit_info
    @commit_info ||= @client.commit('path_to_your_repository', @sha) # path to you repository
  end
end
