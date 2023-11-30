# frozen_string_literal: true

class Map < Bauk::AdventOfCode::BaseMap; end

RSpec.describe Bauk::AdventOfCode::BaseMap do
  context "map1" do
    let(:map) { Map.new 5, 7 }

    it "Starts with empty cells" do
      expect(map.cells.flatten.length).to be 0
      map.insert(1, 3, :a)
      expect(map.cells.flatten.length).to be 1
      expect(map.cell(1, 3)).to eq [:a]
    end

    it "Doesn't allow multiple values unless specified" do
      expect(map.cells.flatten.length).to be 0
      expect { map.insert 1, 3, :a }.not_to raise_error
      expect { map.insert 1, 3, :a }.to raise_error(Bauk::AdventOfCode::Error)
    end
  end
end
