# frozen_string_literal: true

class Map < Bauk::AdventOfCode::BaseMap; end

def rc(row, column)
  { row:, column: }
end
RSpec.describe Bauk::AdventOfCode::BaseMap do
  context "empty map" do
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

  context "simple map" do
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

    it "load a simple line of cells correctly" do
      expect(map.line_of_cells([{ row: 0, column: 0 }, { row: 3, column: 0 }]).flatten).to eq(%w[a A 1 q])
      expect(map.line_of_cells([{ row: 1, column: 1 }, { row: 1, column: 4 }]).flatten).to eq(%w[B C D E])
      expect(map.line_of_cells([{ row: 2, column: 4 }, { row: 2, column: 1 }]).flatten).to eq(%w[5 4 3 2])
      expect(map.line_of_cells([{ row: 4, column: 4 }, { row: 2, column: 4 }]).flatten).to eq(%w[g t 5])
    end

    it "loads a simple path of cells correctly" do
      expect(map.path_to_cells([{ row: 4, column: 4 }, { row: 4, column: 4 }]).flatten).to eq(%w[])
    end

    it "load a multi-point line of cells correctly" do
      expect(map.line_of_cells([{ row: 0, column: 0 }, { row: 3, column: 0 }, { row: 3, column: 0 }]).flatten).to eq(%w[a A 1 q])
    end

    it "fails loading lines if outside boundary" do
      expect { map.line_of_cells([{ row: 4, column: 4 }, { row: 7, column: 4 }]) }.to raise_error Bauk::AdventOfCode::Error
    end
  end

  context "numeric map" do
    let(:map) { Map.from_cell_arrays((0..9).map { |r| (0..9).map { |c| "#{r}_#{c}" } }) }

    let(:expectations) do
      [
        { points: [rc(0, 0), rc(3, 0), rc(3, 0)], line: %w[0_0 1_0 2_0 3_0] },
        { points: [rc(0, 0), rc(3, 0), rc(0, 0)], line: %w[0_0 1_0 2_0 3_0 2_0 1_0 0_0] },
        { points: [rc(0, 0), rc(3, 0), rc(0, 0)], line: %w[0_0 1_0 2_0 3_0 2_0 1_0 0_0] },
        { points: [rc(5, 5), rc(5, 5), rc(5, 5)], line: %w[5_5] },
        { points: [rc(5, 5), rc(5, 5), rc(5, 5)], line: %w[5_5] },
        { points: [rc(5, 5), rc(5, 5), rc(5, 5)], line: %w[5_5] }
      ]
    end

    it "fails when outside range" do
      expect { map.line_of_cells([{ row: 0, column: 0 }, { row: -1, column: 0 }]) }.to raise_error Bauk::AdventOfCode::Error
      expect { map.line_of_cells([{ row: 0, column: 0 }, { row: 0, column: -1 }]) }.to raise_error Bauk::AdventOfCode::Error
      expect { map.line_of_cells([{ row: 0, column: 0 }, { row: 10, column: 0 }]) }.to raise_error Bauk::AdventOfCode::Error
      expect { map.line_of_cells([{ row: 0, column: 0 }, { row: 0, column: 10 }]) }.to raise_error Bauk::AdventOfCode::Error
    end

    it "fails when not a straight line" do
      expect { map.line_of_cells([rc(0, 0), rc(1, 1)]) }.to raise_error Bauk::AdventOfCode::Error
    end

    it "loads expected lines of cells correctly" do
      expectations.each do |expectation|
        expect(map.line_of_cells(expectation[:points])).to eq(expectation[:line])
      end
    end

    it "loads expected path to cells correctly" do
      expectations.each do |expectation|
        expect(map.path_to_cells(expectation[:points])).to eq(expectation[:line][1..])
      end
    end
  end
end
