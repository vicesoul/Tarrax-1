# added compressing for miniMagick
module MiniMagick
  class Image
    def compressing(convert_gif)
      format = self[:format]
      #convert 1st frame for animation gif
      #run_command("convert","#{@path}[0]", "#{@path}")
      format("PNG") if format == "BMP"
    end
  end
end

Technoweenie::AttachmentFu::Processors::MiniMagickProcessor.module_eval do
  def resize_image_with_compressing(img, size)
    img.compressing(true)
    resize_image_without_compressing(img, size)
  end

  alias_method_chain :resize_image, :compressing

  def process_attachment_with_processing_with_compressing
    with_image do |img|
      img.compressing(true)
      self.temp_path = img
    end if image?
    process_attachment_with_processing_without_compressing
  end

  alias_method_chain :process_attachment_with_processing, :compressing
end

