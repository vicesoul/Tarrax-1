
module MailerHelper

  class << self
    include ActionView::Helpers

    def text_to_html(m)
      auto_link( simple_format(m), :urls)
    end

  end

end
