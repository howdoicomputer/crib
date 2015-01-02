describe Crib do
  describe '.api' do
    it 'returns a new Crib::API instance' do
      expect(Crib.api('https://api.github.com')).to be_kind_of Crib::API
    end

    it 'adds the new Crib::API instance to a collection' do
      instance = Crib.api('https://api.github.com')

      expect(Crib.apis.last).to eq instance
    end

    it 'builds a new Sawyer::Agent instance with correct connection options' do
      instance = Crib.api('https://api.github.com',
                          links_parser: Sawyer::LinkParsers::Simple.new) do |c|
        c.headers[:user_agent] = 'crib'
      end

      expect(
        instance._agent.links_parser
      ).to be_kind_of Sawyer::LinkParsers::Simple

      expect(
        instance._agent.instance_variable_get(:@conn).headers[:user_agent]
      ).to eq 'crib'
    end
  end
end
