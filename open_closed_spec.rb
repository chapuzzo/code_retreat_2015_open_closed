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
