# ⛓ Markov

A Crystal library for building Markov Chains and running Markov Processes.

[![Build Status](https://travis-ci.org/mccallofthewild/markov.svg?branch=master)](https://travis-ci.org/mccallofthewild/markov) [![Docs](https://img.shields.io/badge/docs-available-brightgreen.svg)](https://mccallofthewild.github.io/markov/) [![GitHub release](https://img.shields.io/github/release/mccallofthewild/markov.svg)](https://github.com/mccallofthewild/markov/releases)

### _What is a Markov Chain?_

A Markov Chain is essentially a mechanism for guessing probable future events based on a sample of past events.
For a great explanation, watch [this Khan Academy video](https://www.khanacademy.org/computing/computer-science/informationtheory/moderninfotheory/v/markov_chains).

### Visit the [API Documentation](https://mccallofthewild.github.io/markov/) for a more in-depth look at the library's functionality.

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  markov:
    github: mccallofthewild/markov
```
In your terminal, install Crystal dependencies with:
```bash
$ shards install
```
or 
```bash
$ crystal deps
```

## Usage
Begin by requiring the `Markov` module:
```crystal
require "markov"
```
### Basic -- Hello Markov
A classic Markov text generator. This example will work well for small (array-sized) data sets.

NOTE: `Markov::Chain` is a generic type which contains, receives and generates elements of `LinkType`.

We'll start with the sample text:
```crystal 
example_string = "how much wood would a woodchuck chuck if a woodchuck could chuck wood"
```
There are several `Markov::Chain` constructors to choose from. The simplest one takes in a `LinkType` array of elements as `sample` and a `seed` of `LinkType`. `seed` is the element in `sample` you want to start the chain with. If not provided, a random element will be chosen.
```crystal
example_arr = example_string.split(" ") #=> ["how","much","wood","would","a","woodchuck","chuck","if","a","woodchuck","could","chuck","wood"]
seed = example_arr[0] #=> "how"

example_chain = Markov::Chain(String).new sample: example_arr, seed: seed
```
Finally, we'll generate a probable sequence of elements with the `Markov::Chain#generate` method:
```crystal
puts example_chain.generate(10)
```
Output:
```bash
["much", "wood", "would", "a", "woodchuck", "could", "chuck", "if", "a", "woodchuck"]
```
That's it! 

If we wanted to get the elements one at a time, we could use the `Markov::Chain#next` method instead:
```crystal
puts example_chain.next #=> "much"
puts example_chain.next #=> "wood"
puts example_chain.next #=> "would"
```

### Advanced 
This implementation was built for larger data sets, with asynchronous input in mind.

In this example, we will create a `Markov::Chain` which can generate realistic movie titles.

To begin, we instantiate a `Markov::TransitionTable`. A `TransitionTable` is a mechanism for training and implementing Markov processes.

```crystal 
example_table = Markov::TransitionTable(String).new
```

#### `Markov::TransitionTable#add`
Now we'll add a movie title using the `Markov::TransitionTable#add` method:

```crystal
movie_one = %w(the great gatsby) # shortcut syntax for ["the","great","gatsby"]

movie_one.each do |word|
  example_table.add(word)
end
```
`Markov::TransitionTable#add` adds elements one at a time. At a deeper level, it's adding each new word to the previous word's [Transition Matrix](https://en.wikipedia.org/wiki/Stochastic_matrix) (`Markov::TransitionMatrix`).

#### `Markov::TransitionTable#fill`
For syntactic sugar, if we have an array of elements, we can avoid looping through and `#add`-ing them by using the `Markov::TransitionTable#fill` method instead:

```crystal
movie_one = %w(the great gatsby) # shortcut syntax for ["the","great","gatsby"]

example_table.fill table_with: movie_one
```

#### `Markov::TransitionTable#reset`
A problem arises at this point:
```crystal
movie_two = %w(great expectations)
example_table.fill table_with: movie_two
```
The above code sequentially adds each word to the `TransitionTable`. But _The Great Gatsby_ and _Great Expectations_ are two separate movie titles; the "Great" at the beginning of _Great Expectations_ is not a probable transition from the "Gatsby" at the end of _The Great Gatsby_.

To solve this, use `Markov::TransitionTable#reset`. `#reset` clears the `TransitionTable`'s last added key, allowing us to separate titles like so:

```crystal 
movie_one = %w(the great gatsby)
example_table.fill table_with: movie_one

example_table.reset
movie_two = %w(great expectations)
example_table.fill table_with: movie_two

example_table.reset
movie_three = %w(the great escape)
example_table.fill table_with: movie_three
```

#### Implementing the `TransitionTable` with a `Markov::Chain`
Finally, we can put the `TransitionTable` to use by passing it to a `Markov::Chain` constructor as `transition_table`:

```crystal
example_chain = Markov::Chain(String).new transition_table: example_table, seed: "great"
```

#### Handling Dead Ends
With small and/or unique data sets, Markov chains are fallible to reaching dead ends. That is, they can often reach a point where there is nothing to transition to.

When this happens in the `Markov` module, `Markov::Exceptions::EmptyTransitionMatrixException` is raised.

For example:

```crystal
dead_end_array = %w(some say the world will end in fire)
dead_end_chain = Markov::Chain(String).new sample: dead_end_array, seed: "fire"
# nothing comes after "fire", so the chain is at a dead end.
dead_end_chain.next # raises `EmptyTransitionMatrixException`
```

To prevent this, use the `Markov::Chain#on_dead_end` exception handler. 

This method takes in a callback block with arguments of: the `Markov::Chain`'s `@transition_table`, the `Markov::Chain` instance, and the `EmptyTransitionMatrixException` raised.

The block's return value of `LinkType` fills in as the next item in the chain.

```crystal
dead_end_array = %w(some say the world will end in fire)
dead_end_chain = Markov::Chain(String).new sample: dead_end_array, seed: "fire"

dead_end_chain.on_dead_end do |transition_table, chain, exception|
  "some"
end

dead_end_chain.next #=> "some"
dead_end_chain.next #=> "say"
dead_end_chain.next #=> "the"
```

## Contributing

1. Fork it ( https://github.com/mccallofthewild/markov/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [McCall Alexander](https://github.com/mccallofthewild) mccallofthewild - creator, maintainer
