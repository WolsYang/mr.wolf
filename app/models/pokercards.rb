class Card
    def initialize(suit, symbol)
        @suit = suit
        @symbol = symbol
    end
        
    def to_s
      @suit + @symbol
    end
end

class Poker

    def self.cards
      cards =(0...52).map { |i| Card.new(suit(i + 1), symbol(i + 1))}
    end

    def self.suit(number)
        case (number - 1) / 13
            when 0; "黑桃"
            when 1; "紅心"
            when 2; "方塊"
            when 3; "梅花"
        end
    end
    
    def self.symbol(number)
        remain = number % 13
        case remain
            when 0;  "K "
            when 1;  "A "
            when 11; "J "
            when 12; "Q "
            else; sprintf("%-2d", remain)
        end
    end
    
    def self.shuffle
      cards =(0...52).sort_by{rand}.map { |i| Card.new(suit(i + 1), symbol(i + 1))}
    end
end