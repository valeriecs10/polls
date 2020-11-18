class Response < ApplicationRecord
  validate :not_duplicate_response, :not_respond_to_own_poll

  belongs_to :answer_choice,
    class_name: :AnswerChoice,
    foreign_key: :answer_choice_id,
    primary_key: :id 

  belongs_to :respondent,
    class_name: :User,
    foreign_key: :respondent_id,
    primary_key: :id

  has_one :question,
    through: :answer_choice,
    source: :question

  def sibling_responses
    self.id.nil? ? self.question.responses : 
      self.question.responses.where.not('responses.id = ?', self.id)
  end

  def respondent_already_answered?
    sibling_responses.exists?(respondent_id: self.respondent_id)
  end

  def not_duplicate_response
    if respondent_already_answered?
      errors[:user] << 'can\'t answer the same poll twice'
    end
  end

  def respondents_own_poll?
    poll_author_id = Poll
      .joins(questions: :answer_choices)
      .where('answer_choices.id = ?', self.answer_choice_id)
      .pluck('polls.author_id')
      .first

      poll_author_id == self.respondent_id
  end

  def not_respond_to_own_poll
    if respondents_own_poll?
      errors[:user] << 'can\'t answer own poll'
    end
  end
end