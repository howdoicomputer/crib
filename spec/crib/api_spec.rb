describe Crib::API do
  let(:api) do
    Crib::API.new('https://api.github.com') do |c|
      c.headers[:user_agent] = 'crib'
    end
  end

  it 'builds a new Sawyer::Agent instance with correct connection options' do
    expect(api._agent).to be_kind_of Sawyer::Agent

    expect(
      api._agent.instance_variable_get(:@conn).headers[:user_agent]
    ).to eq 'crib'
  end

  it 'returns a new Crib::Request instance upon #method_missing' do
    expect(api.emojis).to be_kind_of Crib::Request
  end
end
