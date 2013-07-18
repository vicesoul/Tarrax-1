module Qti
class ConnectingOnPic < ConnectingLead
  def initialize(opts)
    super(opts)
    @question[:question_type] = 'connecting_on_pic'
  end

  private

  def ensure_correct_format
    @question[:answers].each do |answer|
      %w(left right).each do |direction|
        if answer[:"match_#{direction}_id"]
          if @question[:matches] && @question[:matches][direction.to_sym] && match = @question[:matches][direction.to_sym].find{|m|m[:match_id] == answer[:"match_#{direction}_id"]}
            answer[direction.to_sym] = match[:text]
          end
        end
      end
    end
  end

end
end
