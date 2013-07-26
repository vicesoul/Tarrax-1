/**
 * Copyright (C) 2011 Instructure, Inc.
 *
 * This file is part of Canvas.
 *
 * Canvas is free software: you can redistribute it and/or modify it under
 * the terms of the GNU Affero General Public License as published by the Free
 * Software Foundation, version 3 of the License.
 *
 * Canvas is distributed in the hope that it will be useful, but WITHOUT ANY
 * WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
 * A PARTICULAR PURPOSE. See the GNU Affero General Public License for more
 * details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */

// tinymce doesn't like its plugins being async,
// all dependencies must export to window

define([
  'compiled/editor/stocktiny',
  'i18n!editor',
  'jquery',
  'str/htmlEscape',
  'quizzes_new',
  'i18n!account_homepage',
  'jqueryui/dialog',
  'jquery.form',
  'jquery.instructure_misc_helpers'

], function(tinymce, I18n, $, htmlEscape) {
  var $box;

  var initted = false;

  var TRANSLATIONS = {
    click_to_embed: I18n.t('click_to_embed', 'Click to embed the image'),
    instructions: INST.htmlEscape(I18n.t('instructions', "Paste or type the URL of the image you'd like to embed:")),
    url: INST.htmlEscape(I18n.t('url', 'URL:')),
    alt_text: INST.htmlEscape(I18n.t('alt_text', 'Alternate Text:')),
    search_flickr: I18n.t('search_flickr', 'Search flickr creative commons'),
    loading: I18n.t('loading', 'Loading...'),
    embed_external: I18n.t('embed_external', 'Embed External Image'),
    embed_image: INST.htmlEscape(I18n.t('embed_image', 'Embed Image')),
    image_not_found: I18n.t('image_not_found', 'Image not found, please try a new URL')
  };

  function initShared () {
    var courseId = ENV.context_asset_string.split('_')[1]
    $box = $("<form id='background_image_uploader' action='/courses/" + courseId + "/student_files' method='POST' enctype='multipart/form-data' >" +
        "<table>" +
        "<tr>" +
        "<td>" +
        I18n.t('choose_a_picture', 'choose a picture:') +
        "</td>" +
        "<td>" +
        "<input id='background_bg_image' name='attachment[uploaded_data]' type='file'>" +
        "</td>" +
        "</tr>" +
        "<tr>" +
        "<td>" +
        "</td>" +
        "<td>" +
        // "<input type='submit' value=" + I18n.t('#accounts.homepage.upload', 'Upload') + " class='btn confirm'>" +
        "</td>" +
        "</tr>" +
        "</table>" +
        "</form>").hide();
    
    $('body').append($box);

    var $textUploading = $("<span>上传中...</span>");
    var $inputFile = $box.find("#background_bg_image");
    var $confirm = $box.find(".confirm");

    $('#background_bg_image').on('change', function(){
      $box.submit()
    })
    $box.on('submit', function(e) {
      e.preventDefault();
      $(this).ajaxSubmit({
        clearForm: true,
        dataType: 'json',
        beforeSubmit: function() {
          var imageValidated = validateUploadedImage( $inputFile.val() );
          if(imageValidated) $confirm.hide().after($textUploading);
          return imageValidated;
        },
        success: function(data) {
          var img = "<img src=" + data.url + " />";
          $editor.editorBox('insert_code', img);
          $confirm.show();
          $textUploading.remove();
        },
        complete: function(){
          afterUploadedImageSuccess();
        }
      });


    });

    $box.dialog({
      autoOpen: false,
      width: 425,
      title: TRANSLATIONS.embed_external,
      dialogClass: "instructure_upload_image"
    });
    initted = true;
  }

  tinymce.create('tinymce.plugins.InstructureUploadImage', {
    init: function (editor, url) {
      var thisEditor = $('#' + editor.id);

      editor.addCommand('instructureUploadImage', function (search) {
        if (!initted) initShared();
        $editor = thisEditor; // set shared $editor so images are pasted into the correct editor
        $box.dialog('open');
      });

      editor.addButton('instructure_upload_image', {
        title: '图片上传',
        cmd: 'instructureUploadImage',
        image: url + '/img/button.gif'
      });
    },

    getInfo: function () {
      return {
        longname: 'InstructureUploadImage',
        author: 'Rupert qin',
        authorurl: 'http://www.jiaoxuebang.com',
        infourl: 'http://www.jiaoxuebang.com',
        version: tinymce.majorVersion + '.' + tinymce.minorVersion
      };
    }
  });

  tinymce.PluginManager.add('instructure_upload_image', tinymce.plugins.InstructureUploadImage);
});

