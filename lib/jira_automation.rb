module JiraAutomation
  require 'base64'
  require 'net/http'
  require 'json'
  require 'dotenv'

  Dotenv.load('.env.development')

  BASE_URL = ENV['BASE_URL']
  TOKEN = ENV['TOKEN']
  DEFAULT_PROJECT = ENV['DEFAULT_PROJECT']
  DEFAULT_TEAM = ENV['DEFAULT_TEAM'] ? JSON.parse(ENV['DEFAULT_TEAM']) : nil

  require 'jira_automation/request'
  require 'jira_automation/get'
  require 'jira_automation/post'
  require 'jira_automation/put'
  require 'jira_automation/issue'
  require 'jira_automation/csv_importer'

  def get_issue(id)
    Issue.new(key: id)
  end

  def post_issue(**params)
    Issue.create(**params)
  end
end