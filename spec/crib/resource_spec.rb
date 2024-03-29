describe Crib::Resource do
  subject do
    class Client < described_class
      define 'http://api.fake.com' do |http|
        http.headers[:user_agent] = 'crib'
      end

      [:get, :delete, :head].each do |verb|
        action :"#{verb}_ping" do |id = nil, options = {}|
          send(verb, api.ping(id), options)
        end
      end

      [:post, :put, :patch].each do |verb|
        action :"#{verb}_ping" do |id = nil, data = nil, options = {}|
          send(verb, api.ping(id), data, options)
        end
      end

      action :ping do |id = nil, options = {}|
        api.ping(id)._get(options)
      end
    end
  end
  let(:client) { subject.new }

  describe '#initialize' do
    let(:custom_api) { Crib::API.new('https://api.fake.dev') }

    it 'takes an optional API definition as an argument' do
      expect(subject.new(custom_api).api._agent.inspect).to include '.dev'
    end
  end

  describe '#api' do
    it 'returns an instance of the API definition' do
      expect(client.api).to be_kind_of Crib::API
    end
  end

  describe '#last_response' do
    before { client.ping(10) }

    it 'returns the most recent request' do
      expect(client.last_response.data.params.id).to eq '10'
    end
  end

  describe '.define' do
    it 'builds a new Sawyer::Agent object' do
      expect(client.api._agent).to be_kind_of Sawyer::Agent
    end

    context 'when Sawyer::Agent object built' do
      it 'has the correct connection options' do
        expect(
          client.api._agent.instance_variable_get(:@conn).headers[:user_agent]
        ).to eq 'crib'
      end
    end
  end

  describe '.action' do
    let(:request) do
      client.ping(
        10,
        query: { page: 5 },
        accept: 'application/vnd.fake+json'
      )
    end

    it 'defines an instance method on the Client class' do
      expect(client).to respond_to :ping
    end

    it 'defines methods that work with arguments' do
      expect(request.params.id).to eq '10'
    end

    it 'defines methods that work with query parameters and headers' do
      expect(request.params.page).to eq '5'
      expect(request.headers.accept).to eq 'application/vnd.fake+json'
    end
  end

  describe 'HTTP verb methods' do
    describe '.get' do
      let(:request) do
        client.get_ping(
          10,
          query: { page: 5 },
          accept: 'application/vnd.fake+json'
        )
      end

      it 'handles arguments, query parameters, and headers' do
        expect(request.params.id).to eq '10'
        expect(request.params.page).to eq '5'
        expect(request.headers.accept).to eq 'application/vnd.fake+json'
      end
    end
  end

  [:post, :put, :patch].each do |verb|
    describe ".#{verb}" do
      let(:request) do
        client.send(
          :"#{verb}_ping",
          10,
          'pong',
          query: { page: 5 },
          headers: { accept: 'application/vnd.fake+json' }
        )
      end

      it 'handles arguments, request body, query parameters, and headers' do
        expect(request.params.id).to eq '10'
        expect(request.body).to eq 'pong'
        expect(request.params.page).to eq '5'
        expect(request.headers.accept).to eq 'application/vnd.fake+json'
      end
    end
  end

  describe '.delete' do
    let(:request) do
      client.delete_ping(
        10,
        query: { page: 5 },
        headers: { accept: 'application/vnd.fake+json' }
      )
    end

    it 'handles arguments, query parameters, and headers' do
      expect(request.params.id).to eq '10'
      expect(request.params.page).to eq '5'
      expect(request.headers.accept).to eq 'application/vnd.fake+json'
    end
  end

  describe '.head' do
    before { client.head_ping(10, accept: 'application/vnd.fake+json') }

    it 'handles arguments, query parameters, and headers' do
      expect(
        client.last_response.headers[:content_type]
      ).to eq 'application/json'
    end
  end
end
