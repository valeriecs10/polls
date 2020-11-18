class User < ApplicationRecord
  validates :username, presence: true

  has_many :authored_polls,
    class_name: :Poll,
    foreign_key: :author_id,
    primary_key: :id 
    
  has_many :responses,
    class_name: :Response,
    foreign_key: :respondent_id,
    primary_key: :id 

  def completed_polls
    polls_with_completion_counts
      .having('COUNT(DISTINCT questions.id) = COUNT(responses.id)')
  end

  def incomplete_polls
    polls_with_completion_counts
      .having('COUNT(DISTINCT questions.id) > COUNT(responses.id)')
      .having('COUNT(responses.id > 0')
  end

  private

  def polls_with_completion_counts
    joins_sql = <<-SQL 
      LEFT OUTER JOIN (
        SELECT
          *
        FROM
          responses
        WHERE
          respondent_id = #{self.id}
      ) AS responses ON answer_choices.id = responses.answer_choice_id
    SQL

    Poll.joins(questions: :answer_choices)
      .joins(joins_sql)
      .group('polls.id')
  end
end