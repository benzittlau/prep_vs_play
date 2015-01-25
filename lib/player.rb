class Player
  attr_accessor :attempt_eagerness, :prep_eagerness, :game, :state
  attr_accessor :action, :action_turns_spent, :score, :successes

  ATTEMPT = 0
  PREP = 1

  ACTION_NAMES = {
    0 => "Attempting",
    1 => "Prepping"
  }


  def initialize(options)
    initialize_knowledge
    @attempt_eagerness = options[:attempt_eagerness]
    @prep_eagerness = options[:prep_eagerness]
    @game = options[:game]
    @score = 0
    @successes = 0
  end

  def current_state
    return {
      :action => ACTION_NAMES[@action],
      :action_turns_spent => @action_turns_spent,
      :successes => @successes,
      :score => @score
    }
  end

  def take_turn
    choose_action if action.nil?
    action_turns_spent += 1
    execute_if_ready
  end

  def execute_if_ready
    if game.ready_to_execute?(action, action_turns_spent)
      if action == ATTEMPT
        perform_attempt
      elsif action == PREP
        preform_prep
      end

      clear_action
    end
  end

  def perform_attempt
    score -= game.attempt_cost

    if game.attempt_with_values(variable_guesses_for_attempt)
      score += game.reward_of_success
      successes += 1
      #TODO: reset_game?
    else
      score -= game.cost_of_failure
    end
  end

  def variable_guesses_for_attempt
    @variable_guesses = {}
    @variable_knowledge.each do |variable, known_bad_values|
      @remaining_values = (game.min_value(variable)..game.max_value(variable)).delete_if{|v| known_bad_values.include? v}
      @variable_guesses[variable] = @remaining_values.sample
    end

    @variable_guesses
  end

  def perform_prep
    score -= game.prep_cost

    # Return here will be {:variable => :a, :value => 7}
    fact = game.reveal_new_fact(@variable_knowledge)
    @variable_knowledge[fact[:variable]] << fact[:value]
  end

  def clear_action
    @action = nil
    @action_turns_spent = 0
  end

  def initialize_knowledge
    #@variable_knowledge = {:a => [2,6], :b => [], :c => [7,2]}
    #@result_knowledge = [57]
    # TODO: DO I want the variables to be orthogonoal (think powers of 2)
    # Knowledge will store the values the player knows
    # not to be in the problem space
    # Results will be where we store from experience values that
    # were not correct
    
    @result_knowledge = []
    @variable_knowledge = {}
    variables = game.variables
    variables.each {|v| @variable_knowledge[v] = []}
  end


  def choose_action
    attempt_watermark = prep_eagerness / (attempt_eagerness + prep_eagerness)
    if (rand(100)/100) > attempt_watermark
      @action = ATTEMPT
    else
      @action = PREP
    end
  end
end
