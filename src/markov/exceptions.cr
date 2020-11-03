# Holds all custom exceptions in the `Markov` module.
module Markov::Exceptions
  # Thrown when a method cannot execute due to a `TransitionMatrix` being empty.
  class EmptyTransitionMatrixException < Exception
    def initialize(method : String, message : String = "")
      super "Cannot complete ##{method} with an empty `TransitionMatrix`. \n \t #{message}"
    end
  end

  # Thrown when a method cannot execute due to a `TransitionTable` being empty.
  class EmptyTransitionTableException < Exception
    def initialize(method : String, message : String = "")
      super "Cannot complete method #{method} with an empty `TransitionTable`. \n \t #{message}"
    end
  end

  # Thrown when a method cannot execute due to an invalid `seed`.
  class InvalidSeedException < Exception
    def initialize(message : String = "")
      super "`seed` not valid! \n \t #{message}"
    end
  end
end
