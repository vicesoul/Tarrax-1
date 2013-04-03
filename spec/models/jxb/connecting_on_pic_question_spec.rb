require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper.rb')

describe QuizQuestion::ConnectingOnPicQuestion do
  before :each do
    question_data = {
      'id' => '3',
      'question_type' => 'connecting_on_pic_question',
      'points_possible' => 50,
      "answers" => [
        {"comments"=>"",
          "left"=>"ball-3",
          "id"=>2939,
          "right"=>"ball-4ball-5",
          "match_right_id"=>7948,
          "match_left_id"=>6633},
      ]
    }.with_indifferent_access

    @q = QuizQuestion::Base.from_question_data question_data
  end

  it "should calculate correct answers" do
    answer_data = {
      "question_3_answer_2939_left"=>"ball-5ball-6",
    }.with_indifferent_access

    user_answer = QuizQuestion::UserAnswer.new(@q.question_id, @q.points_possible, answer_data)
    user_answer.total_parts = @q.total_answer_parts

    correct_answers = @q.correct_answer_parts(user_answer)
    correct_answers.should == 1
    incorrect_answers = @q.incorrect_answer_parts(user_answer)
    incorrect_answers.should == 1
  end
end
