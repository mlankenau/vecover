defmodule VecoverSpec do
  use ESpec

  describe "generate_vim_data" do
    it do
      sample = [[{{Vecover, 0}, {0, 1}}, {{Vecover, 0}, {1, 0}}, {{Vecover, 0}, {1, 0}},
                {{Vecover, 0}, {0, 1}}, {{Vecover, 3}, {1, 0}}, {{Vecover, 4}, {0, 1}},
                {{Vecover, 6}, {1, 0}}, {{Vecover, 7}, {1, 0}}, {{Vecover, 9}, {1, 0}}]]
      result = Vecover.generate_vim_data(sample)
      expect result |> to(eq "'./lib/vecover.ex': [[9, 7, 6, 3], [4]] ")
    end
  end
end
