class QuizQuestion::DragAndDropQuestion < QuizQuestion::FillInMultipleBlanksQuestion
  def find_chosen_answer(variable, response)
    @question_data[:answers].detect{ |answer| answer[:id] == response.to_i } || { :text => nil, :id => nil, :weight => 0 }
  end

  def answer_text(answer)
    answer[:id]
  end
end
