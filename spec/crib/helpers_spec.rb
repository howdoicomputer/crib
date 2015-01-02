describe Crib::Helpers do
  let(:helpers) { Crib::Helpers }

  describe '.construct_uri' do
    it 'constructs a forward-slash-separated URI from its arguments' do
      expect(helpers.construct_uri('markdown')).to eq 'markdown'

      expect(helpers.construct_uri('markdown', 'raw')).to eq 'markdown/raw'

      expect(
        helpers.construct_uri('repos', 'rails', 'rails', 'issues', 13037)
      ).to eq 'repos/rails/rails/issues/13037'
    end
  end
end
