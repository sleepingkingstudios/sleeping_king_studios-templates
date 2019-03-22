# spec/rspec_spec.rb

require 'erubi'
require 'byebug'

RSpec.describe 'rspec.erb' do
  let(:locals) do
    {
      :file_path     => 'spec/ichi_spec.rb',
      :file_name     => 'ichi_spec',
      :relative_path => []
    } # end locals
  end # let
  let(:template) do
    File.read 'lib/rspec.erb'
  end # let
  let(:rendered) do
    binding = tools.hash.generate_binding(locals)

    eval(Erubi::Engine.new(template).src, binding)
  end # let
  let(:raw) do
    <<-RUBY
      # spec/ichi_spec.rb

      require 'ichi'

      RSpec.describe Ichi do
        pending
      end # describe
    RUBY
  end # let
  let(:expected) do
    offset = raw.match(/\A( +)/)[1].length

    tools.string.map_lines(raw) { |line| line[offset..-1] || "\n" }
  end # let

  def tools
    SleepingKingStudios::Tools::Toolbelt.instance
  end # method tools

  it { expect(rendered).to be == expected }

  describe 'with a superclass' do
    let(:locals) do
      super().merge(
        :file_path     => 'spec/ichi/ni/san_spec.rb',
        :file_name     => 'san_spec',
        :relative_path => %w(ichi ni)
      ) # end locals
    end # let
    let(:raw) do
      <<-RUBY
        # spec/ichi/ni/san_spec.rb

        require 'ichi/ni/san'

        RSpec.describe Ichi::Ni::San do
          pending
        end # describe
      RUBY
    end # let

    it { expect(rendered).to be == expected }
  end # describe
end # describe
