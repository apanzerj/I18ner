require "spec_helper"

RSpec.describe I18ner do
  it "has a version number" do
    expect(I18ner::VERSION).not_to be nil
  end

  describe I18ner::Base do
    describe '.new' do
      let(:instance) { described_class.new(`pwd`.chomp) }

      describe 'project' do
        subject{ instance.instance_variable_get(:@project) }

        it{ is_expected.to start_with(`pwd`.chomp) }
        it{ is_expected.to eq(`pwd`.chomp + "/config/locales/en.yml") }
      end
    end

    describe '#run' do
      let(:instance) { described_class.new(`pwd`.chomp) }
      let(:input) { { a: 'b' } }
      before do
        allow(instance).to receive(:content).and_return(input)
      end

      subject { instance.run; instance.items }

      describe 'simple hash' do
        it { is_expected.to eq(["a => b"]) }
      end

      describe 'hash within a hash' do
        let(:input) do
          { a: "b", c: "d", e: { f: "g", h: "i" } }
        end

        it { is_expected.to eq [ "a => b", "c => d", "e.f => g", "e.h => i" ].sort }
      end

      describe 'several hashes within hashes' do
        let(:input) do
          { a: { b: { c: { d: 'e' } } } }
        end

        it { is_expected.to eq [ "a.b.c.d => e" ] }

        describe 'with more hashes' do
          let(:input) { { a: { b: { c: { d: { 'one' => 'two' }, 'banana' => 'e', f: 'g', h: 'i', j: 'k' } } } } }

          it { is_expected.to eq ["a.b.c.banana => e", "a.b.c.d.one => two", "a.b.c.f => g", "a.b.c.h => i", "a.b.c.j => k"] }
        end
      end
    end
  end


  describe "feature parity" do
    with_i18n_config({en: {sodas: {sugar_free: {coke_zero: "Coke Zero"}}}}) do |translations|
      let(:instance) { described_class::Base.new(`pwd`.chomp) }
      subject { instance.run; instance.items }

      before do
        allow(instance).to receive(:content).and_return(translations)
      end

      it 'reads translations properly' do
        expect(I18n.t('sodas.sugar_free.coke_zero')).to eq('Coke Zero')
        expect(I18n.t('sodas.sugar_free.coke_zero')).not_to eq('Coke Zeroo')
      end

      it 'looks up the correct key/value' do
        key, value = subject.first.split(" => ")
        expect(I18n.t(key.gsub('en.',''))).to eq(value)
      end
    end
  end
end
