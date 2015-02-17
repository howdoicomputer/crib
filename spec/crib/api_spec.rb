describe Crib::API do
  subject do
    described_class.new('http://api.fake.com') do |http|
      http.headers[:user_agent] = 'crib'
    end
  end

  describe '#initialize' do
    it 'builds a new Sawyer::Agent object' do
      expect(subject._agent).to be_kind_of Sawyer::Agent
    end

    context 'when Sawyer::Agent object built' do
      it 'has the correct connection options' do
        expect(
          subject._agent.instance_variable_get(:@conn).headers[:user_agent]
        ).to eq 'crib'
      end
    end
  end

  describe '#_agent' do
    it 'returns the request handler' do
      expect(subject._agent).to be_kind_of Sawyer::Agent
    end
  end

  describe '#_last_response' do
    context 'when no requests were made' do
      it 'returns nothing' do
        expect(subject._last_response).to be_nil
      end
    end

    context 'when at least one request was made' do
      before { subject.ping._get }

      it 'returns the most recent request' do
        expect(subject._last_response).to be_kind_of Sawyer::Response
      end
    end
  end

  describe '#method_missing' do
    it 'returns a new Request instance' do
      expect(subject.emojis).to be_kind_of Crib::Request
    end
  end
end
