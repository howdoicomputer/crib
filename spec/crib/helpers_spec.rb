describe Crib::Helpers do
  subject { Crib::Helpers }

  describe '.construct_path' do
    it 'returns a REST-friendly path' do
      expect(subject.construct_path('ping')).to eq 'ping'
      expect(subject.construct_path('ping', 10)).to eq 'ping/10'
    end
  end

  describe Crib::Helpers::InheritableAttribute do
    subject do
      Class.new(Object) do
        extend Crib::Helpers::InheritableAttribute
        inheritable_attr :_api
      end
    end

    it 'has a reader with an empty inherited attribute' do
      expect(subject._api).to be_nil
    end

    it 'has a reader with empty inherited attributes in a derived Class' do
      expect(Class.new(subject)._api).to be_nil
    end

    it 'provides an attribute copy in sub-Classes' do
      subject._api = []

      expect(
        subject._api.object_id
      ).not_to eq Class.new(subject)._api.object_id
    end

    it 'provides a writer' do
      subject._api = [:api]

      expect(subject._api).to eq [:api]
    end

    it 'inherits attributes' do
      subject._api = [:api]
      subclass_a = Class.new(subject)
      subclass_a._api << :another_api
      subclass_b = Class.new(subject)
      subclass_b._api << :different_api

      expect(subject._api).to eq [:api]
      expect(subclass_a._api).to eq [:api, :another_api]
      expect(subclass_b._api).to eq [:api, :different_api]
    end

    it 'does not inherit attributes if set explicitely' do
      subject._api = [:api]
      subclass = Class.new(subject)
      subclass._api = [:another_api]

      expect(subclass._api).to eq [:another_api]
    end
  end
end
