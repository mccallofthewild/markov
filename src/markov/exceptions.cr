module Markov::Exceptions

  
  class EmptyTransitionMatrixException < Exception
    def initialize(method : String, message : String = "")
      super "Cannot complete ##{method} with an empty `TransitionMatrix`. \n \t #{message}"
    end
  end

  
  class EmptyTransitionTableException < Exception
    def initialize(method : String, message : String = "")
      super "Cannot accept empty `TransitionTable` for method #{method}. \n \t #{message}"
    end
  end

end
