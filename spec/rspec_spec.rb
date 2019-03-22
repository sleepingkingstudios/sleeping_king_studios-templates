# frozen_string_literal: true

require 'erubi'
require 'byebug'

RSpec.describe 'rspec.erb' do
  let(:locals) do
    {
      file_path:     'spec/ichi_spec.rb',
      file_name:     'ichi_spec',
      relative_path: []
    }
  end
  let(:template) do
    File.read 'lib/rspec.erb'
  end
  let(:rendered) do
    binding = tools.hash.generate_binding(locals)

    # rubocop:disable Security/Eval
    eval(Erubi::Engine.new(template).src, binding)
    # rubocop:enable Security/Eval
  end
  let(:raw) do
    <<-RUBY
      # frozen_string_literal: true

      require 'ichi'

      RSpec.describe Ichi do
        pending
      end
    RUBY
  end
  let(:expected) do
    offset = raw.match(/\A( +)/)[1].length

    tools.string.map_lines(raw) { |line| line[offset..-1] || "\n" }
  end

  def tools
    SleepingKingStudios::Tools::Toolbelt.instance
  end

  it { expect(rendered).to be == expected }

  describe 'with a relative path' do
    let(:locals) do
      super().merge(
        file_path:     'spec/ichi/ni/san_spec.rb',
        file_name:     'san_spec',
        relative_path: %w[ichi ni]
      )
    end
    let(:raw) do
      <<-RUBY
        # frozen_string_literal: true

        require 'ichi/ni/san'

        RSpec.describe Ichi::Ni::San do
          pending
        end
      RUBY
    end

    it { expect(rendered).to be == expected }
  end
end
