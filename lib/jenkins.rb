### How to launch the bot
# SLACK_API_TOKEN=slack_api_token bundle exec ruby lib/jenkins.rb
###

require 'slack-ruby-bot'
require_relative 'github'

class JenkinsBot < SlackRubyBot::Bot

  GREEN_SUCCESS = "36a64f" # jenkins attachment's color for success

  AUTHOR =
    {
      'aovertus' => 'aovertus'
    }

  # /Koolicar Web/
  scan(//) do |client, data, match|
    @attachment = data[:attachments][0]
    notify_author if author_has_to_be_notified?
  end

  def self.notify_author
    @github_client = ::GithubClient.new(sha)
    generate_slack
  end

  def self.get_author
    author = AUTHOR[@github_client.commit_author]
    return author if author.present?
    'default_user' # prevent default user if test suite failed.
  end

  def self.author_has_to_be_notified?
    @attachment.present? && !tests_succeeded?
  end

  def self.tests_succeeded?
    @attachment.color == GREEN_SUCCESS
  end

  def self.sha
    @attachment.text.match('\[(.*)\]')[1]
  end

  def self.build_message
    "Hi there ! Test suite failed because of one of your last commit,\n" +
    "please check it out : <#{@github_client.commit_url}| see my commit >\n" +
    "> Jenkins result : <#{@attachment.text.match('\<(.*)\>')[1].sub!('display/redirect', 'console')}>"
  end

  def self.generate_slack
    client = Slack::Web::Client.new(token: "slack_api_token")
    client.chat_postMessage(
      channel: "@#{get_author}",
      text: build_message,
      as_user: true
    )
  end
end

JenkinsBot.run
