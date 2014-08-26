ARGV[0] = 'poker.txt'
class Card
  include Comparable

  attr_accessor :face, :suit

  def initialize values
    @face, @suit = values[0], values[1]
  end

  def value
    case @face
      when 'A' then 14
      when 'K' then 13
      when 'Q' then 12
      when 'J' then 11
      when 'T' then 10
      else @face.to_i
    end
  end

  def <=> other
    self.value <=> other.value
  end

end

class Player
  attr_accessor :cards, :facestring, :suitstring

  include Enumerable

  HAND_RANKS = ["RoyalFlush" => 10, "StraighFlush" => 9, "FourofKind" => 8,
               "FullHouse" => 7, "Flush" => 6, "Straight" => 5, "ThreeofKind" => 4,
                "TwoPair" => 3, "Pair" => 2, "HighCard" => 1]

  def initialize
    @cards = []
    @facestring, @suitstring = [], []
  end

  def each &block
    @cards.each do |card|
      if block_given?
        block.call card
      else
        yield card
      end
    end
  end

  def recieve_card card
    @cards << card
    @facestring << card.face
    @suitstring << card.suit
  end

  def suits
    @cards.each{ |card| card.suit }.uniq
  end

  def hand
    return 10 if straight? && flush?  && @facestring.join('').scan(//).count > 0
    return 9 if straight? && flush?
    return 8 if fourofkind?
    return 7 if fullhouse?
    return 6 if flush?
    return 5 if straight?
    return 4 if threeofkind?
    return 3 if twopair?
    return 2 if pair?
    return 1
  end

  def straight?
    return false unless @facestring.uniq == @facestring
    @cards.sort!
    @cards.min.value == @cards.max.value-4
  end

  def flush?
    @suitstring.uniq.count == 1
  end

  def fourofkind?
    @facestring.each{ |face| return true if @facestring.join('').scan(/#{face}/).count == 4 }
    false
  end

  def fullhouse?
    pair? && threeofkind?
  end

  def pair?
    @facestring.each{ |face| return true if @facestring.join('').scan(/#{face}/).count == 2 }
    false
  end

  def threeofkind?
    @facestring.each{ |face| return true if @facestring.join('').scan(/#{face}/).count == 3 }
    false
  end

  def twopair?
    return false unless pair?
    @facestring.uniq.count == 3
  end

end

File.open(ARGV[0]).each_line do |line|
  left, right = line[0..14], line[15..30]
  next unless right
  player1 = Player.new
  left.split(' ').flatten.each do |hand|
    card = Card.new(hand)
    player1.recieve_card(card)
  end
  player2 = Player.new
  right.split(' ').flatten.each do |hand|
    card = Card.new(hand)
    player2.recieve_card(card)
  end
  if player1.hand == player2.hand
    puts 'none'
    next
  end
  puts player1.hand > player2.hand ? 'left' : 'right'
end
