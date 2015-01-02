describe Crib::API do
  let(:api) { Crib::API.new('https://api.github.com') }

  it 'builds a Sawyer::Agent instance upon initialization' do
    expect(api._agent).to be_kind_of Sawyer::Agent
  end

  it 'returns a new Crib::Request instance upon #method_missing' do
    expect(api.emojis).to be_kind_of Crib::Request
  end
end
