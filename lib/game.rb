class Game
  attr_accessor :variables
  attr_accessor :attempt_cost, :prep_cost, :reward_of_success, :cost_of_failure
  attr_accessor :attempt_turn_count, :prep_turn_count, :answer

  ATTEMPT = 0
  PREP = 1

  ACTION_NAMES = {
    0 => "Attempting",
    1 => "Prepping"
  }

  def initialize(options = {})
    @variables = options.fetch( :variables, [:a] )
    @min_value = options.fetch( :min_value, 1 )
    @max_value = options.fetch( :min_value, 10 )

    @attempt_cost = options.fetch( :attempt_cost, 0)
    @prep_cost = options.fetch( :prep_cost, 0)

    @attempt_turn_count = options.fetch( :attempt_turn_count, 0)
    @prep_turn_count = options.fetch( :prep_turn_count, 0)

    @reward_of_success = options.fetch( :reward_of_success, 1)
    @cost_of_failure = options.fetch( :cost_of_failure, 0)

    generate_correct_answer
  end

  def min_value(_variable)
    @min_value
  end

  def max_value(_variable)
    @max_value
  end

  def generate_correct_answer
    @answer = {}
    @variables.each do |variable|
      @answer[variable] = possible_values_for(variable).sample
    end
  end

  def possible_values_for(_variable)
    (@min_value..@max_value).to_a
  end

  def permutation_count
    @variables.count * (min_value..max_value).count
  end

  def ready_to_execute?(action, action_turns_spent)
    if action == ATTEMPT
      return (action_turns_spent >= @attempt_turn_count)
    elsif action = PREP
      return (action_turns_spent >= @prep_turn_count)
    end
  end

  def guessed_correctly?(guess)
    correct = true
    @answer.each do |variable, value|
      correct = false unless guess[variable] == value
    end

    correct
  end

  def reveal_new_fact(variable_knowledge)
    remaining_unknowns = {}
    @variables.each do |variable|
      remaining_unknowns[variable] = possible_values_for(variable).
        delete_if{|val| variable_knowledge[variable].include? val}.
        delete_if{|val| @answer[variable] == val}
    end

    remaining_unknowns.delete_if{|_k,v| v.empty?}

    return false if remaining_unknowns.empty?

    variable = remaining_unknowns.keys.sample
    {:variable => variable, :value => remaining_unknowns[variable].sample}
  end

  def permutation_count_with_knowledge(variable_knowledge, previous_wrong_attempts)
    permutations = [{}]
    remaining_values = {}
    variable_knowledge.each do |variable, facts|
      remaining_values = possible_values_for(variable) - facts

      new_permutations = []
      remaining_values.each do |value|
        permutations.each do |permutation|
          new_permutation = Hash[permutation]
          new_permutation[variable] = value
          new_permutations << new_permutation
        end
      end

      permutations = new_permutations
    end

    remaining_possibilities = permutations - previous_wrong_attempts

    remaining_possibilities.count
  end
end
