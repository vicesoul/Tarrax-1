module Qti
class ConnectingLead < AssessmentItemConverter
  include Canvas::Migration::XMLHelper

  def initialize(opts)
    super(opts)
    @question[:matches] = {:left => [], :right => []}
    @question[:question_type] = 'connecting_lead_question'
    @custom_type = opts[:custom_type]
  end

  def parse_question_data
    match_map = {}
    get_canvas_matches(match_map)
    get_canvas_answers(match_map)
    attach_feedback_values(@question[:answers])

    get_feedback()
    ensure_correct_format

    @question
  end

  private

  def ensure_correct_format
    @question[:answers].each do |answer|
      answer[:center] = answer[:text] if answer[:text].present?
      answer[:center_html] = answer[:html] if answer[:html].present?
      %w(left right).each do |direction|
        if answer[:"match_#{direction}_id"]
          if @question[:matches] && @question[:matches][direction.to_sym] && match = @question[:matches][direction.to_sym].find{|m|m[:match_id] == answer[:"match_#{direction}_id"]}
            answer[direction.to_sym] = match[:text]
          end
        end
      end
    end
  end

  def get_canvas_matches(match_map)
    @doc.css('choiceInteraction').each do |ci|
      ci.css('simpleChoice').each do |sc|
        match = {}
        dir, mat_id = sc['identifier'].split('_', 2)
        @question[:matches][dir.to_sym] << match
        match_map[sc['identifier']] = match
        if mat_id =~ /(\d+)/
          match[:match_id] = $1.to_i
        else
          match[:match_id] = unique_local_id
        end
        match[:text] = sc.text.strip
      end
    end
  end

  def get_canvas_answers(match_map)
    answer_map = {}
    @doc.css('choiceInteraction').each do |ci|
      answer = {}
      @question[:answers] << answer
      answer_map[ci['responseIdentifier']] = answer
      extract_answer!(answer, ci.at_css('prompt'))
      answer[:id] = unique_local_id
    end

    # connect to match
    @doc.css('responseIf, responseElseIf').each do |r_if|
      answer_mig_id = nil
      match_mig_id = nil
      if match = r_if.at_css('match')
        answer_mig_id = get_node_att(match, 'variable', 'identifier')
        match_mig_id = match.at_css('baseValue[baseType=identifier]').text rescue nil
      end
      if answer = answer_map[answer_mig_id]
        answer[:feedback_id] = get_feedback_id(r_if)
        if r_if.at_css('setOutcomeValue[identifier=SCORE] sum') && match = match_map[match_mig_id]
          dir, mat_id = match_mig_id.split('_', 2)
          answer[:"match_#{dir}_id"] = match[:match_id]
        end
      end
    end
  end

  def extract_answer!(answer, node)
    text, html = detect_html(node)
    answer[:text] = text
    if html.present?
      answer[:html] = html
    end
  end

end
end
