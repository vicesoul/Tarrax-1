# based on SimpleCaptcha controller

class CaptchaController < ApplicationController
  include SimpleCaptcha::ImageHelpers

  def simple_captcha  #:nodoc
    send_data(
      generate_simple_captcha_image(
        :image_style => params[:image_style],
        :distortion => params[:distortion], 
        :simple_captcha_key => params[:simple_captcha_key]),
      :type => 'image/jpeg',
      :disposition => 'inline',
      :filename => 'simple_captcha.jpg')
  end

  def render_captcha
    render :template => 'simple_captcha/render_captcha', :layout => false
  end
end
