describe Crib::Resource do
  let(:client) do
    class Client < Crib::Resource
      define 'https://api.github.com' do |c|
        c.headers[:user_agent] = 'crib'
      end

      action :user do |user|
        api.users(user)._get
      end

      action :issues do |repo, options = {}|
        api.repos(*repo.split('/')).issues._get(options)
      end
    end
  end
  let(:instance) { client.new }

  describe '#initialize' do
    let(:custom_api) { Crib::API.new('https://api.github.dev') }

    it 'takes an optional API definition as an argument' do
      expect(client.new(custom_api).api._agent.inspect).to include '.dev'
    end
  end

  describe '#api' do
    it 'contains an instance of Crib::API' do
      expect(instance.api).to be_kind_of Crib::API
    end
  end

  describe '#last_response' do
    before { instance.user('rafalchmiel') }

    it 'returns the latest Sawyer::Response' do
      expect(instance.last_response.headers[:content_length]).to eq '1328'
    end
  end

  describe '.define' do
    it 'builds a new Sawyer::Agent instance with correct connection options' do
      expect(instance.api._agent).to be_kind_of Sawyer::Agent

      expect(
        instance.api._agent.instance_variable_get(:@conn).headers[:user_agent]
      ).to eq 'crib'
    end
  end

  describe '.action' do
    it 'defines an instance method on the Client class' do
      expect(instance).to respond_to :user
    end

    it 'defines methods that work with arguments' do
      expect(instance.user('rafalchmiel').id).to eq 1687642
    end

    it 'defines methods that work with query parameters and headers' do
      expect(
        instance.issues(
          'rails/rails',
          query: { per_page: 2 },
          accept: 'application/vnd.github+json'
        ).count
      ).to eq 2
    end
  end
end
