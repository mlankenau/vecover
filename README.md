# Vecover

Vecover is bringing your coverage reports in elixir to vim. 

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add vecover to your list of dependencies in `mix.exs`:

        def deps do
          [
            {:vecover, github: "mlankenau/vecover"},
            {:espec, "~> 0.8.21", only: :test}
          ]
        end

  2. Add vecover to your project


        def project do
          [
            ...
            test_coverage: [tool: Vecover],
            ...
          ]
        end

  3. Run tests

        e.g. mix espec --cover

  4. In vim...

        :so coverage.vim

## Credits

The vim code is a copy of nyarly/Simplecov-Vim. Thanx for the work!
