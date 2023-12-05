# frozen_string_literal: true

class Map < Bauk::AdventOfCode::BaseMap; end

RSpec.describe Bauk::AdventOfCode::BaseMap do # rubocop:disable Metrics/BlockLength
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

  context "map2" do
    let(:map) { Map.from_lines %w[abcdefg ABCDEFG 1234567 qwertyu asdfghj zxcvbnm] }

    it "loads the map correctly" do
      expect(map.cell(0, 0)).to eq ["a"]
      expect(map.cell(1, 1)).to eq ["B"]
      expect(map.cell(2, 2)).to eq ["3"]
      expect(map.cell(3, 3)).to eq ["r"]
      expect(map.cell(4, 4)).to eq ["g"]
      expect(map.cell(5, 5)).to eq ["n"]
      expect { map.cell(6, 6) }.to raise_error NoMethodError
    end

    it "loads columns correctly" do
      expect(map.columns.length).to eq 7
      expect(map.column(0)).to eq(%w[a A 1 q a z].map { |i| [i] })
      expect(map.column(6)).to eq(%w[g G 7 u j m].map { |i| [i] })
      expect { map.column(7) }.to raise_error Bauk::AdventOfCode::Error
    end

    it "loads rows correctly" do
      expect(map.rows.length).to eq 6
      expect(map.row(0)).to eq(%w[a b c d e f g].map { |i| [i] })
      expect(map.row(4)).to eq(%w[a s d f g h j].map { |i| [i] })
      expect { map.row(7) }.to raise_error Bauk::AdventOfCode::Error
    end

    it "load line of cells correctly" do
      expect(map.line_of_cells([{ row: 0, column: 0 }, { row: 3, column: 0 }]).flatten).to eq(%w[a A 1 q])
      expect(map.line_of_cells([{ row: 1, column: 1 }, { row: 1, column: 4 }]).flatten).to eq(%w[B C D E])
      expect(map.line_of_cells([{ row: 2, column: 4 }, { row: 2, column: 1 }]).flatten).to eq(%w[5 4 3 2])
    end
  end
end
