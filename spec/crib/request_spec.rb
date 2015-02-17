describe Crib::Request do
  subject { described_class.new(api) }
  let(:api) { Crib::API.new('http://api.fake.com') }

  describe '#_get' do
    let(:request) do
      subject.ping(10)._get(
        query: { page: 5 },
        accept: 'application/vnd.fake+json'
      )
    end

    it 'requests the path relative to the endpoint' do
      expect(request.url).to eq 'http://api.fake.com/ping/10?page=5'
    end

    it 'handles arguments, query parameters, and headers' do
      expect(request.params.id).to eq '10'
      expect(request.params.page).to eq '5'
      expect(request.headers.accept).to eq 'application/vnd.fake+json'
    end
  end

  [:_post, :_put, :_patch].each do |verb|
    describe "##{verb}" do
      let(:request) do
        subject.ping(10).send(
          verb,
          'pong',
          query: { page: 5 },
          headers: { accept: 'application/vnd.fake+json' }
        )
      end

      it 'requests the path relative to the endpoint' do
        expect(request.url).to eq 'http://api.fake.com/ping/10?page=5'
      end

      it 'handles arguments, request body, query parameters, and headers' do
        expect(request.params.id).to eq '10'
        expect(request.body).to eq 'pong'
        expect(request.params.page).to eq '5'
        expect(request.headers.accept).to eq 'application/vnd.fake+json'
      end
    end
  end

  describe '#_delete' do
    let(:request) do
      subject.ping(10)._delete(
        query: { page: 5 },
        headers: { accept: 'application/vnd.fake+json' }
      )
    end

    it 'requests the path relative to the endpoint' do
      expect(request.url).to eq 'http://api.fake.com/ping/10?page=5'
    end

    it 'handles arguments, query parameters, and headers' do
      expect(request.params.id).to eq '10'
      expect(request.params.page).to eq '5'
      expect(request.headers.accept).to eq 'application/vnd.fake+json'
    end
  end

  describe '#_head' do
    before { subject.ping(10)._head(accept: 'application/vnd.fake+json') }

    it 'handles arguments, query parameters, and headers' do
      expect(api._last_response.headers[:content_length]).to eq '146'
    end
  end
end
