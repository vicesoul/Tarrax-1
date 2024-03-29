# Copyright (c) 2008 [Sur http://expressica.com]

class CreateSimpleCaptchaData < ActiveRecord::Migration
  tag :predeploy

  def self.up
    create_table :simple_captcha_data do |t|
      t.string :key, :limit => 40
      t.string :value, :limit => 6
      t.timestamps
    end
  end

  def self.down
    drop_table :simple_captcha_data
  end
end
