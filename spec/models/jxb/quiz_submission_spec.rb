require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper.rb')

describe QuizSubmission do
  describe ".score_question" do
    it "should score a connecting_lead_question" do
      q = connecting_lead_question_data

      # 1 wrong answer
      user_answer = QuizSubmission.score_question(q, {
        "question_1_answer_7396_left" => "3855", #wrong
        "question_1_answer_6081_left" => "6061", #wrong
        "question_1_answer_4224_left" => "1397",
        "question_1_answer_7397_left" => "2369",
        "question_1_answer_7398_left" => "6065",
        "question_1_answer_7399_left" => "5779",

        "question_1_answer_7396_right" => "3562",
        "question_1_answer_6081_right" => "1500",
        "question_1_answer_4224_right" => "8513",
        "question_1_answer_7397_right" => "6067",
        "question_1_answer_7398_right" => "6068",
        "question_1_answer_7399_right" => "6069",
      })
      user_answer.delete(:points).should be_close(41.67, 0.01)
      user_answer.should == {
        :question_id => 1, :correct => "partial", :text => "",
        :answer_7396_left => "3855",
        :answer_6081_left => "6061",
        :answer_4224_left => "1397",
        :answer_7397_left => "2369",
        :answer_7398_left => "6065",
        :answer_7399_left => "5779",
        :answer_7396_right => "3562",
        :answer_6081_right => "1500",
        :answer_4224_right => "8513",
        :answer_7397_right => "6067",
        :answer_7398_right => "6068",
        :answer_7399_right => "6069",
      }

      # 1 wrong answer but no partial credit allowed
      user_answer = QuizSubmission.score_question(q.merge(:allow_partial_credit => false), {
        "question_1_answer_7396_left" => "3855", #wrong
        "question_1_answer_6081_left" => "6061", #wrong
        "question_1_answer_4224_left" => "1397",
        "question_1_answer_7397_left" => "2369",
        "question_1_answer_7398_left" => "6065",
        "question_1_answer_7399_left" => "5779",

        "question_1_answer_7396_right" => "3562",
        "question_1_answer_6081_right" => "1500",
        "question_1_answer_4224_right" => "8513",
        "question_1_answer_7397_right" => "6067",
        "question_1_answer_7398_right" => "6068",
        "question_1_answer_7399_right" => "6069",
      })
      user_answer.should == {
        :question_id => 1, :correct => false, :points => 0, :text => "",
        :answer_7396_left => "3855",
        :answer_6081_left => "6061",
        :answer_4224_left => "1397",
        :answer_7397_left => "2369",
        :answer_7398_left => "6065",
        :answer_7399_left => "5779",
        :answer_7396_right => "3562",
        :answer_6081_right => "1500",
        :answer_4224_right => "8513",
        :answer_7397_right => "6067",
        :answer_7398_right => "6068",
        :answer_7399_right => "6069",
      }

      # all wrong answers
      user_answer = QuizSubmission.score_question(q, {
        "question_1_answer_7396_left" => "3855",
        "question_1_answer_6081_left" => "6061",
        "question_1_answer_4224_left" => "2369",
        "question_1_answer_7397_left" => "1397",
        "question_1_answer_7398_left" => "5779",
        "question_1_answer_7399_left" => "6065",

        "question_1_answer_7396_right" => "1500",
        "question_1_answer_6081_right" => "3562",
        "question_1_answer_4224_right" => "6067",
        "question_1_answer_7397_right" => "8513",
        "question_1_answer_7398_right" => "6069",
        "question_1_answer_7399_right" => "6068",
      })
      user_answer.should == {
        :question_id => 1, :correct => false, :points => 0, :text => "",
        :answer_7396_left => "3855",
        :answer_6081_left => "6061",
        :answer_4224_left => "2369",
        :answer_7397_left => "1397",
        :answer_7398_left => "5779",
        :answer_7399_left => "6065",

        :answer_7396_right => "1500",
        :answer_6081_right => "3562",
        :answer_4224_right => "6067",
        :answer_7397_right => "8513",
        :answer_7398_right => "6069",
        :answer_7399_right => "6068",
      }

      # all correct answers
      user_answer = QuizSubmission.score_question(q, {
        "question_1_answer_7396_left" => "6061",
        "question_1_answer_6081_left" => "3855",
        "question_1_answer_4224_left" => "1397",
        "question_1_answer_7397_left" => "2369",
        "question_1_answer_7398_left" => "6065",
        "question_1_answer_7399_left" => "5779",

        "question_1_answer_7396_right" => "3562",
        "question_1_answer_6081_right" => "1500",
        "question_1_answer_4224_right" => "8513",
        "question_1_answer_7397_right" => "6067",
        "question_1_answer_7398_right" => "6068",
        "question_1_answer_7399_right" => "6069",
      })
      user_answer.should == {
        :question_id => 1, :correct => true, :points => 50, :text => "",
        :answer_7396_left => "6061",
        :answer_6081_left => "3855",
        :answer_4224_left => "1397",
        :answer_7397_left => "2369",
        :answer_7398_left => "6065",
        :answer_7399_left => "5779",

        :answer_7396_right => "3562",
        :answer_6081_right => "1500",
        :answer_4224_right => "8513",
        :answer_7397_right => "6067",
        :answer_7398_right => "6068",
        :answer_7399_right => "6069",
      }

      # no answer shouldn't be treated as a blank string, breaking undefined_if_blank
      QuizSubmission.score_question(q, { "undefined_if_blank" => "1" }).should == {
        :question_id => 1, :correct => "undefined", :points => 0, :text => "",
        :answer_7396_left => "",
        :answer_6081_left => "",
        :answer_4224_left => "",
        :answer_7397_left => "",
        :answer_7398_left => "",
        :answer_7399_left => "",

        :answer_7396_right => "",
        :answer_6081_right => "",
        :answer_4224_right => "",
        :answer_7397_right => "",
        :answer_7398_right => "",
        :answer_7399_right => "",
      }
    end

    it "should score a connecting_on_pic_question" do
      q = connecting_on_pic_question_data

      # 1 wrong answer
      user_answer = QuizSubmission.score_question(q, {
        "question_1_answer_1111_left" => "ball-2",
        "question_1_answer_2222_left" => "ball-3ball-4",
        "question_1_answer_5555_left" => "ball-6ball-7",
        "question_1_answer_8888_left" => "ball-9ball-10",
      })
      user_answer.delete(:points).should be_close(43.75, 0.01)
      user_answer.should == {
        :question_id => 1, :correct => "partial", :text => "",
        :answer_1111_left => "ball-2",
        :answer_2222_left => "ball-3ball-4",
        :answer_5555_left => "ball-6ball-7",
        :answer_8888_left => "ball-9ball-10",
      }

      # 1 wrong answer
      user_answer = QuizSubmission.score_question(q, {
        "question_1_answer_1111_left" => "ball-2",
        "question_1_answer_2222_left" => "ball-3ball-4",
        "question_1_answer_5555_left" => "ball-6ball-7ball-11",
        "question_1_answer_8888_left" => "ball-9ball-10ball-11",
      })
      user_answer.delete(:points).should be_close(43.75, 0.01)
      user_answer.should == {
        :question_id => 1, :correct => "partial", :text => "",
        :answer_1111_left => "ball-2",
        :answer_2222_left => "ball-3ball-4",
        :answer_5555_left => "ball-6ball-7ball-11",
        :answer_8888_left => "ball-9ball-10ball-11",
      }

      # 1 wrong answer but no partial credit allowed
      user_answer = QuizSubmission.score_question(q.merge(:allow_partial_credit => false), {
        "question_1_answer_1111_left" => "ball-2",
        "question_1_answer_2222_left" => "ball-3ball-4",
        "question_1_answer_5555_left" => "ball-6ball-7",
        "question_1_answer_8888_left" => "ball-9ball-10",
      })
      user_answer.should == {
        :question_id => 1, :correct => false, :points => 0, :text => "",
        :answer_1111_left => "ball-2",
        :answer_2222_left => "ball-3ball-4",
        :answer_5555_left => "ball-6ball-7",
        :answer_8888_left => "ball-9ball-10",
      }

      # all wrong answers
      user_answer = QuizSubmission.score_question(q, {
        "question_1_answer_1111_left" => "ball-3",
        "question_1_answer_2222_left" => "ball-6ball-7",
        "question_1_answer_5555_left" => "ball-9ball-10",
        "question_1_answer_8888_left" => "ball-2ball-4",
      })
      user_answer.should == {
        :question_id => 1, :correct => false, :points => 0, :text => "",
        :answer_1111_left => "ball-3",
        :answer_2222_left => "ball-6ball-7",
        :answer_5555_left => "ball-9ball-10",
        :answer_8888_left => "ball-2ball-4",
      }

      # all correct answers
      user_answer = QuizSubmission.score_question(q, {
        "question_1_answer_1111_left" => "ball-2",
        "question_1_answer_2222_left" => "ball-3ball-4",
        "question_1_answer_5555_left" => "ball-6ball-7",
        "question_1_answer_8888_left" => "ball-9ball-10ball-11",
      })
      user_answer.should == {
        :question_id => 1, :correct => true, :points => 50, :text => "",
        :answer_1111_left => "ball-2",
        :answer_2222_left => "ball-3ball-4",
        :answer_5555_left => "ball-6ball-7",
        :answer_8888_left => "ball-9ball-10ball-11",
      }

      # no answer shouldn't be treated as a blank string, breaking undefined_if_blank
      QuizSubmission.score_question(q, { "undefined_if_blank" => "1" }).should == {
        :question_id => 1, :correct => "undefined", :points => 0, :text => "",
        :answer_1111_left => "",
        :answer_2222_left => "",
        :answer_5555_left => "",
        :answer_8888_left => "",
      }
    end

  end
end
