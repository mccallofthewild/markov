module Markov::Exceptions

  # Thrown when a method cannot execute due to the `TransitionMatrix` being empty.
  class EmptyTransitionMatrixException < Exception
    def initialize(method : String, message : String = "")
      super "Cannot complete ##{method} with an empty `TransitionMatrix`. \n \t #{message}"
    end
  end

  # Thrown when a method cannot execute due to the `TransitionTable` being empty.
  class EmptyTransitionTableException < Exception
    def initialize(method : String, message : String = "")
      super "Cannot accept empty `TransitionTable` for method #{method}. \n \t #{message}"
    end
  end

end
