describe Crib::DSL do
  let(:client) do
    class Client < Crib::DSL
      define 'https://api.github.com' do |c|
        c.headers[:user_agent] = 'crib'
      end

      action :user do |user|
        api.users(user)._get
      end

      action :issues do |repo, options = {}|
        api.repos(*repo.split('/')).issues._get(options)
      end
    end.new
  end

  describe '#api' do
    it 'contains an instance of Crib::API' do
      expect(client.api).to be_kind_of Crib::API
    end
  end

  describe '#last_response' do
    before { client.user('rafalchmiel') }

    it 'returns the latest Sawyer::Response' do
      expect(client.last_response.headers[:content_length]).to eq '1328'
    end
  end

  describe '.define' do
    it 'builds a new Sawyer::Agent instance with correct connection options' do
      expect(client.api._agent).to be_kind_of Sawyer::Agent

      expect(
        client.api._agent.instance_variable_get(:@conn).headers[:user_agent]
      ).to eq 'crib'
    end
  end

  describe '.action' do
    it 'defines an instance method on the Client class' do
      expect(client).to respond_to :user
    end

    it 'defines methods that work with arguments' do
      expect(client.user('rafalchmiel').id).to eq 1687642
    end

    it 'defines methods that work with query parameters and headers' do
      expect(
        client.issues(
          'rails/rails',
          query: { per_page: 2 },
          accept: 'application/vnd.github+json'
        ).count
      ).to eq 2
    end
  end
end
