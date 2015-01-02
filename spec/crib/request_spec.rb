describe Crib::Request do
  let(:api) { Crib::API.new('https://api.github.com') }
  let(:request) { Crib::Request.new(api) }

  describe '#_get' do
    it 'requests the URI relative to the endpoint, with GET method' do
      expect(request.users('rafalchmiel')._get.id).to eq 1687642
    end

    it 'works with query parameters and headers' do
      expect(
        request.repos('rails', 'rails').issues._get(
          query: { per_page: 2 },
          accept: 'application/vnd.github+json'
        ).count
      ).to eq 2
    end
  end

  describe '#_post' do
    it 'requests the URI relative to the endpoint, with POST method' do
      expect(
        request.markdown._post(query: { text: '**test**' })
      ).to eq "<p><strong>test</strong></p>\n"
    end
  end

  describe '#_put' do
    it 'requests the URI relative to the endpoint, with PUT method' do
      expect(request.ping._put).to eq 'true'
    end
  end

  describe '#_patch' do
    it 'requests the URI relative to the endpoint, with PATCH method' do
      expect(request.ping._patch).to eq 'true'
    end
  end

  describe '#_delete' do
    it 'requests the URI relative to the endpoint, with DELETE method' do
      expect(request.ping._delete).to eq 'true'
    end
  end

  describe '#_head' do
    before { request.ping._head }

    it 'requests the URI relative to the endpoint, with HEAD method' do
      expect(api._last_response.headers[:content_length]).to eq '4'
    end
  end
end
