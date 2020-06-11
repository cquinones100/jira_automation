require 'spec_helper'
require './lib/jira_automation/csv_importer'
require './lib/jira_automation/issue'
require 'ostruct'

RSpec.describe JiraAutomation::CsvImporter do
  describe 'deleting tickets' do
    let(:ticket_123) do
      instance_double(JiraAutomation::Issue, key: 'ticket-123')
    end

    let(:ticket_126) do
      instance_double(JiraAutomation::Issue, key: 'ticket-126')
    end

    before do
      allow(JiraAutomation::Issue)
        .to receive(:find)
        .and_return(ticket_123, ticket_126)

      expect(ticket_123).to receive(:delete).and_return(OpenStruct.new('ok?' => true))
      expect(ticket_126).to receive(:delete).and_return(OpenStruct.new('ok?' => true))
    end

    it do
      described_class.new(path: './spec/fixtures/delete.csv').import
    end
  end
end