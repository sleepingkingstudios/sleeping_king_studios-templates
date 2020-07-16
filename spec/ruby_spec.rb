# frozen_string_literal: true

require 'erubi'

RSpec.describe 'ruby.erb' do
  let(:locals) do
    {
      file_path:     'lib/ichi.rb',
      file_name:     'ichi',
      relative_path: []
    }
  end
  let(:template) do
    File.read 'lib/ruby.erb'
  end
  let(:rendered) do
    binding = tools.hsh.generate_binding(locals)

    # rubocop:disable Security/Eval
    eval(Erubi::Engine.new(template).src, binding)
    # rubocop:enable Security/Eval
  end
  let(:raw) do
    <<-RUBY
      # frozen_string_literal: true

      module Ichi

      end
    RUBY
  end
  let(:expected) do
    offset = raw.match(/\A( +)/)[1].length

    tools.str.map_lines(raw) { |line| line[offset..-1] || "\n" }
  end

  def tools
    SleepingKingStudios::Tools::Toolbelt.instance
  end

  it { expect(rendered).to be == expected }

  describe 'with a superclass' do
    let(:locals) { super().merge superclass: 'Ni::San' }
    let(:raw) do
      <<-RUBY
        # frozen_string_literal: true

        class Ichi < Ni::San

        end
      RUBY
    end

    it { expect(rendered).to be == expected }
  end

  describe 'with a relative path' do
    let(:locals) do
      super().merge(
        file_path:     'lib/ichi/ni/san.rb',
        file_name:     'san',
        relative_path: %w[ichi ni]
      )
    end
    let(:raw) do
      <<-RUBY
        # frozen_string_literal: true

        require 'ichi/ni'

        module Ichi::Ni
          module San

          end
        end
      RUBY
    end

    it { expect(rendered).to be == expected }

    describe 'with a superclass' do
      let(:locals) { super().merge superclass: 'Yon::Go' }
      let(:raw) do
        <<-RUBY
          # frozen_string_literal: true

          require 'ichi/ni'

          module Ichi::Ni
            class San < Yon::Go

            end
          end
        RUBY
      end

      it { expect(rendered).to be == expected }
    end
  end
end
