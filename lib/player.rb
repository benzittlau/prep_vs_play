class Player
  attr_accessor :attempt_eagerness, :prep_eagerness, :game, :state
  attr_accessor :action, :action_turns_spent, :score, :successes, :failures
  attr_accessor :previous_wrong_attempts, :variable_knowledge

  ATTEMPT = 0
  PREP = 1

  ACTION_NAMES = {
    0 => "Attempting",
    1 => "Prepping"
  }


  def initialize(options)
    @attempt_eagerness = options.fetch(:attempt_eagerness, 1)
    @prep_eagerness = options.fetch(:prep_eagerness,1)
    @game = options[:game]
    @score = 0
    @successes = 0
    @failures = 0

    initialize_knowledge
    clear_action
  end

  def current_state
    return {
      :action => action_name,
      :action_turns_spent => @action_turns_spent,
      :successes => @successes,
      :failures => @failures,
      :score => @score,
      :probability_of_correct_guess => probability_of_correct_guess
    }
  end

  def attempt_count
    @successes + @failures
  end

  def action_name
    ACTION_NAMES[@action]
  end


  def probability_of_correct_guess
    remaining_permutation_count = @game.permutation_count_with_knowledge(@variable_knowledge, @previous_wrong_attempts)
    1.to_f / remaining_permutation_count
  end

  def take_turn
    clear_action if @complete
    choose_action if action.nil?
    @action_turns_spent += 1
    execute_if_ready
  end

  def execute_if_ready
    if game.ready_to_execute?(action, @action_turns_spent)
      if action == ATTEMPT
        perform_attempt
      elsif action == PREP
        perform_prep
      end

      @complete = true
    end
  end

  def perform_attempt
    @score -= @game.attempt_cost

    # Make sure we're making a *new* guess, not one
    # that failed before
    current_guess = nil
    new_guess = false
    while !new_guess
      current_guess = variable_guesses_for_attempt
      new_guess = true unless previous_wrong_attempts.include? current_guess
    end

    if game.guessed_correctly?(current_guess)
      @successes += 1
      @score += @game.reward_of_success
      if game.clear_wrong_attempts_on_success
        @previous_wrong_attempts = []
      end
    else
      @failures += 1
      @previous_wrong_attempts << current_guess
      @score -= @game.cost_of_failure
    end
  end

  def perform_prep
    @score -= game.prep_cost

    # Return here will be {:variable => :a, :value => 7}
    fact = game.reveal_new_fact(@variable_knowledge)
    @variable_knowledge[fact[:variable]] << fact[:value]
  end

  def variable_guesses_for_attempt
    @variable_guesses = {}
    @variable_knowledge.each do |variable, known_bad_values|
      @remaining_values = (game.min_value(variable)..game.max_value(variable)).to_a.delete_if{|v| known_bad_values.include? v}
      @variable_guesses[variable] = @remaining_values.sample
    end

    @variable_guesses
  end

  def clear_action
    @complete = false
    @action = nil
    @action_turns_spent = 0
  end

  def initialize_knowledge
    #@variable_knowledge = {:a => [2,6], :b => [], :c => [7,2]}
    # TODO: DO I want the variables to be orthogonoal (think powers of 2)
    # Knowledge will store the values the player knows
    # not to be in the problem space
    # Results will be where we store from experience values that
    # were not correct
    
    @variable_knowledge = {}
    variables = @game.variables
    variables.each {|v| @variable_knowledge[v] = []}

    @previous_wrong_attempts = []
  end


  def choose_action
    attempt_watermark = prep_eagerness.to_f / (attempt_eagerness + prep_eagerness)
    if (probability_of_correct_guess == 1) || ((rand(100).to_f/100) > attempt_watermark)
      @action = ATTEMPT
    else
      @action = PREP
    end
  end
end
