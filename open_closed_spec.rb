describe 'game' do

  it 'accepts a map and rules' do
    map = Map.new
    rules = Rules.new
    game = Game.new map, rules

    expect(game.map()).to eq(map)
  end

  xit 'applies the rules' do
    map = Map.new
    rules = Rules.new
    game = Game.new map, rules

    expect(rules).to receive(:apply).with(position, neighbourhood)
    game.evolve
  end

  it 'kills a cell when rules say so' do
    position = Position.new
    rules = KillEmAll.new
    map = Map.new
    game = Game.new map, rules

    expect(rules).to receive(:apply).with(position).and_call_original
    expect(position).to receive(:neighbours).and_call_original
    expect(map).to receive(:set_dead).with(position).and_call_original

    game.evolve_position(position)
  end

  it 'spawns a cell when rules say so' do
    position = Position.new
    rules = Overpolulate.new
    map = Map.new
    game = Game.new map, rules

    expect(rules).to receive(:apply).with(position).and_call_original
    expect(position).to receive(:neighbours).and_call_original
    expect(map).to receive(:set_alive).with(position).and_call_original

    game.evolve_position(position)
  end
end

describe 'map' do

  it 'knows status of its cells' do
    map = Map.new
    position = Position.new
    map.set_alive(position)
    expect(map.ask(position)).to eq :alive

    map.set_dead(position)
    expect(map.ask(position)).to eq :dead
  end
end

describe 'TwoDimensions map' do
  it 'represents itself as a string' do
    map = TwoDimensions.new 1, 1

    expect(map.to_s).to eq('.')

    map = TwoDimensions.new 2, 2

    expect(map.to_s).to eq(". .\n. .")
  end
end


describe 'ThreeDimensions map' do
  it 'represents itself as a string' do
    map = ThreeDimensions.new 1, 1, 1

    expect(map.to_s).to eq(
"""
  +===+
 / o /
+===+
""".chomp.gsub(/^\n/, '')
)

    map = ThreeDimensions.new 2, 1, 1

    expect(map.to_s).to eq(
"""
  +===+===+
 / o / o /
+===+===+
""".chomp.gsub(/^\n/, '')
)

    map = ThreeDimensions.new 2, 1, 2

    expect(map.to_s).to eq(
"""
    +===+===+
   / o / o /
  +---+---+
 / o / o /
+===+===+
""".chomp.gsub(/^\n/, '')
)

    map = ThreeDimensions.new 2, 2, 2

    expect(map.to_s).to eq(
"""
    +===+===+
   / o / o /
  +---+---+
 / o / o /
+===+===+
    +===+===+
   / o / o /
  +---+---+
 / o / o /
+===+===+
""".chomp.gsub(/^\n/, '')
)

    map = ThreeDimensions.new 3, 3, 3

    expect(map.to_s).to eq(

"""
      +===+===+===+
     / o / o / o /
    +---+---+---+
   / o / o / o /
  +---+---+---+
 / o / o / o /
+===+===+===+
      +===+===+===+
     / o / o / o /
    +---+---+---+
   / o / o / o /
  +---+---+---+
 / o / o / o /
+===+===+===+
      +===+===+===+
     / o / o / o /
    +---+---+---+
   / o / o / o /
  +---+---+---+
 / o / o / o /
+===+===+===+
""".chomp.gsub(/^\n/, '')
)
  end
end

describe 'Position' do
  it 'knows its neighbourhood' do
    position = Position.new

    expect(position.neighbours).to be_instance_of(Array)
  end
end

class Game

  def initialize map, rules
    @rules = rules
    @map = map
  end

  def map
    @map
  end

  def rules
    @rules
  end

  def evolve_position position
    next_state = @rules.apply(position)
    @map.send('set_' + next_state.to_s, position)
  end
end

class Map
  def initialize
    @positions = {}
  end

  def set_alive position
    @positions[position] = :alive
  end

  def set_dead position
    @positions[position] = :dead
  end

  def ask position
    @positions[position]
  end
end

class TwoDimensions < Map
  DIMENSIONS = 2

  def initialize x, y
    @x = x
    @y = y
  end

  def to_s
    ([ ('. ' * @x).strip ] * @y).join "\n"
  end
end

class ThreeDimensions < Map
  DIMENSIONS = 3

  def initialize x, y, z
    @x = x
    @y = y
    @z = z
  end

  def to_s
    skewed_to_s
  end

  private
    def skewed_to_s
      @y.times.map { |row|
        draw_floor row
      }.join("\n")
    end

    def draw_floor row
      [
        header(@x, @z),
        @z.times.reverse_each.map {|depth|
          draw_depth(depth, row)
        }.zip((@z - 1).times.reverse_each.map {|depth|
          ((padding(depth * 2 + 2) + depth_separator(@x)))
        }).flatten.compact.join("\n"),
        footer(@x)
      ].join("\n")
    end

    def draw_depth depth, row
      padded_with(depth * 2 + 1) do
        joint_with '/' do
          @x.times.map {|col|
            'o'.center(3)
          }
        end
      end
    end

    def joint_with char, &block
      content = block.call
      (['/'] * (content.size + 1)).zip(content).join
    end

    def padded_with depth, &block
      padding(depth) + block.call
    end

    def wrap content, gutter = "\n"
      ([gutter] * 2).join content
    end

    def separator size, gutter
      (['+'] * (size + 1)).join(gutter)
    end

    def horizontal_separator size
      separator size, '==='
    end

    def depth_separator size
      separator size, '---'
    end

    def footer x
      horizontal_separator x
    end

    def header x, z
      padding(z * 2) + horizontal_separator(x)
    end

    def padding size
      ' ' * size
    end
end

class Position
  def neighbours
    []
  end
end

class Rules
end

class KillEmAll < Rules
  def apply position
    position.neighbours
    :dead
  end
end

class Overpolulate < Rules
  def apply position
    position.neighbours
    :alive
  end
end
