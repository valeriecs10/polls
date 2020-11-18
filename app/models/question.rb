class Question < ApplicationRecord
  validates :text, presence: true

  has_many :answer_choices,
    class_name: :AnswerChoice,
    foreign_key: :question_id,
    primary_key: :id,
    dependent: :destroy

  belongs_to :poll,
    class_name: :Poll,
    foreign_key: :poll_id,
    primary_key: :id

  def n_plus_1_results
    answers = self.answer_choices
    answers_count = {}

    answers.each do |answer|
      answers_count[answer.text] = answer.responses.length
    end
    answers_count
  end

  def better_results
    answers = self.answer_choices.includes(:responses)
    answers_count = {}

    answers.each do |answer|
      answers_count[answer.text] = answer.responses.length
    end
    answers_count
  end

  def best_results
    AnswerChoice
      .select('answer_choices.*, COUNT(responses.id) AS total')
      .left_outer_joins(:responses)
      .where('answer_choices.question_id = ?', self.id)
      .group('answer_choices.id')
  end
end