require "./TransitionMatrix.cr"

module Markov
  
  # A `TransitionTable` represents a mapping of keys to `TransitionMatrix`'s.
  class TransitionTable(LinkType) < Hash(LinkType, TransitionMatrix(LinkType))
    

    @last_added_key : LinkType | Nil

    # Creates a new empty `TransitionMatrix`.
    def initialize 
      super
    end

    # Makes it possible to use `#to_json` and `#from_json` (see Crystal docs)
    def initialize(pull : JSON::PullParser)
      super()
      hash = self
      pull.read_object do |key|
        if pull.kind == :null
          pull.read_next
        elsif key == "last_added_key"
          @last_added_key = typeof(key).new(pull)
        else
          hash[key] = TransitionMatrix(typeof(key)).new(pull) # V is the value type, as in `Hash(K, V)`
        end
      end
      hash
    end

    
    # Inserts `key` into last added `key`'s `TransitionMatrix`, if applicable, 
    # and creates new `TransitionMatrix` for `key` if not already there.
    def add(key : LinkType)
      if @last_added_key
        last_matrix = self[@last_added_key]
        last_matrix.add(key)
      end
      if ! self.has_key? key
        self[key] = TransitionMatrix(LinkType).new
      end
      @last_added_key = key
    end
    
    # Sequentially fills `TransitionTable` with values in given `Array` using `#add` method.
    # Just a shortcut for looping through array and `#add`ing elements.
    # ```
    # string_array = %w(some say the world will end in fire)
    # tt = Markov::TransitionTable(String).new
    # tt.fill table_with: string_array
    # ```
    def fill( table_with sample : Array(LinkType) )
      sample.each do |key|
        add(key)
      end
    end
    
    # Returns probable transition from the `TransitionMatrix` associated with key provided.
    # Will raise `EmptyTransitionMatrixException` if no probable transition is available.
    # ```
    # string_array = %w(some say the world will end in fire)
    # tt = Markov::TransitionTable(String).new
    # tt.fill table_with: string_array
    #
    # tt.probable? after: "world" #=> "will"
    # tt.probable? after: "fire" # raises `EmptyTransitionMatrixException`
    # ```
    def probable( after key : LinkType ) : LinkType
      self[key].probable_transition
    end

    # Returns probable transition from the `TransitionMatrix` associated with key provided.
    # Returns `nil` if no probable transition is available.
    # ```
    # string_array = %w(some say the world will end in fire)
    # tt = Markov::TransitionTable(String).new
    # tt.fill table_with: string_array
    #
    # tt.probable? after: "world" #=> "will"
    # tt.probable? after: "fire" #=> nil
    # ```
    def probable?( after key : LinkType ) : LinkType | Nil
      begin
        return probable key
      rescue Markov::Exceptions::EmptyTransitionMatrixException
        return nil
      end
    end

    # Returns random key. 
    # Will raise `EmptyTransitionTableException` if `TransitionTable` is empty.
    def random_key : LinkType
      begin 
        self.keys.sample(1).first
      rescue IndexError
        raise Exceptions::EmptyTransitionTableException.new(
          method: "random_key", 
          message: "Use TransitionTable#add or TransitionTable#fill to populate the TransitionTable instance and try again."
        )
      end
    end

    # Returns random `TransitionMatrix` from table.
    def random_matrix : TransitionMatrix(LinkType)
      self[random_key]
    end

    # Resets the `TransitionTable`'s last added key between non-sequential sets of training data.
    # ```
    # movie_one = %w(the great gatsby)
    # movie_two = %w(great expectations)
    # tt = Markov::TransitionTable(String).new
    # tt.fill table_with: movie_one
    # tt.reset()
    # tt.fill table_with: movie_two
    
    # tt.probable? after: "gatsby" #=> nil
    # tt.probable? after: "great" #=> "expectations" or "gatsby"
    # ```
    def reset
      @last_added_key = nil
    end
    

  end
  
end