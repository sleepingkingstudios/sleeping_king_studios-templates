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
    binding = tools.hash.generate_binding(locals)

    # rubocop:disable Security/Eval
    eval(Erubi::Engine.new(template).src, binding)
    # rubocop:enable Security/Eval
  end
  let(:raw) do
    <<-RUBY
      # lib/ichi.rb

      module Ichi

      end # module
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

  describe 'with a superclass' do
    let(:locals) { super().merge superclass: 'Ni::San' }
    let(:raw) do
      <<-RUBY
        # lib/ichi.rb

        class Ichi < Ni::San

        end # class
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
        # lib/ichi/ni/san.rb

        require 'ichi/ni'

        module Ichi::Ni
          module San

          end # module
        end # module
      RUBY
    end

    it { expect(rendered).to be == expected }

    describe 'with a superclass' do
      let(:locals) { super().merge superclass: 'Yon::Go' }
      let(:raw) do
        <<-RUBY
          # lib/ichi/ni/san.rb

          require 'ichi/ni'

          module Ichi::Ni
            class San < Yon::Go

            end # class
          end # module
        RUBY
      end

      it { expect(rendered).to be == expected }
    end
  end
end
