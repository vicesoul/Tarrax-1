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

define([
  'INST' /* INST */,
  'i18n!select_content_dialog',
  'jquery' /* $ */,
  'jquery.ajaxJSON' /* ajaxJSON */,
  'jquery.instructure_forms' /* ajaxJSONFiles, getFormData, errorBox */,
  'jqueryui/dialog',
  'compiled/jquery/fixDialogButtons' /* fix dialog formatting */,
  'jquery.instructure_misc_helpers' /* replaceTags, getUserServices, findLinkForService */,
  'jquery.instructure_misc_plugins' /* showIf */,
  'jquery.keycodes' /* keycodes */,
  'jquery.loadingImg' /* loadingImage */,
  'jquery.templateData' /* fillTemplateData */
], function(INST, I18n, $) {

$(document).ready(function() {
  var external_services = null;
  var $dialog = $("#select_context_content_dialog");

  // dialog     /shared/add_assignment.html.erb
  attachAddAssignment($("#assignments_select .module_item_select"));

  INST = INST || {};
  INST.selectContentDialog = function(options) {
    var for_modules = options.for_modules;
    var select_button_text = options.select_button_text || I18n.t('buttons.add_item', "Add Item");
    var holder_name = options.holder_name || "module";
    var dialog_title = options.dialog_title || I18n.t('titles.add_item_to_module', "Add Item to Module");
    var allow_external_urls = for_modules;
    var select_type = options.type || "";
      $dialog.data('submitted_function', options.submit);
      $dialog.find(".context_module_content").showIf(for_modules);
      $dialog.find(".holder_name").text(holder_name);
      $dialog.find(".add_item_button").text(select_button_text);
      $dialog.find(".select_item_name").showIf(!options.no_name_input);
      if(allow_external_urls && !external_services) {
        var $services = $("#content_tag_services").empty();
        $.getUserServices('BookmarkService', function(data) {
          for(var idx in data) {
            service = data[idx].user_service;
            $service = $("<a href='#' class='bookmark_service no-hover'/>");
            $service.addClass(service.service);
            $service.data('service', service);
            $service.attr('title', I18n.t('titles.find_links_using_service', 'Find links using %{service}', {service: service.service}));
            var $img = $("<img/>");
            $img.attr('src', '/images/' + service.service + '_small_icon.png');
            $service.append($img);
            $service.click(function(event) {
              event.preventDefault();
              $.findLinkForService($(this).data('service').service, function(data) {
                $("#content_tag_create_url").val(data.url);
                $("#content_tag_create_title").val(data.title);
              });
            });
            $services.append($service);
            $services.append("&nbsp;&nbsp;");
          }
        });
      }
      $("#select_context_content_dialog #external_urls_select :text").val("");
      $("#select_context_content_dialog #context_module_sub_headers_select :text").val("");
      $("#select_context_content_dialog").dialog({
        title: dialog_title,
        width: 400
      }).fixDialogButtons();
      $("#select_context_content_dialog .module_item_option").hide();
      $("#" + select_type + "s_select").show()
      .find(".module_item_select").val("new").change()

      $("#" + select_type + "s_select").find("input[type=text]:first").focus()


  }


  $("#select_context_content_dialog .module_item_select").change(function() {
    if($(this).val() == "new") {
      $(this).parents(".module_item_option").find(".new").show().focus().select();
    } else {
      $(this).parents(".module_item_option").find(".new").hide()
    }
    if( !$(this).parents(".module_item_option").is("#assignments_select") ){
      $(this).parents(".module_item_option").find("input[type=text]:first").focus()
    }
  })

    $("#select_context_content_dialog .cancel_button").click(function() {
      $dialog.find('.alert').remove();
      $dialog.dialog('close');
    });
    $("#select_context_content_dialog .item_title").keycodes('return', function() {
      $(this).parents(".module_item_option").find(".add_item_button").click();
    });
    $("#select_context_content_dialog .add_item_button").click(function() {
      var submit = function(item_data) {
        $dialog.dialog('close');
        $dialog.find('.alert').remove();
        var submitted = $dialog.data('submitted_function');
        if(submitted && $.isFunction(submitted)) {
          submitted(item_data);
        }
      };
      var item_type = $("#select_context_content_dialog .module_item_option:visible").attr("id").replace("s_select", "")
      if(item_type == 'external_url') {
        var item_data = {
          'item[type]': item_type,
          'item[id]': $("#select_context_content_dialog .module_item_option:visible:first .module_item_select").val(),
          'item[indent]': $("#content_tag_indent").val()
        }
        item_data['item[url]'] = $("#content_tag_create_url").val();
        item_data['item[title]'] = $("#content_tag_create_title").val();
        submit(item_data);
      } else if(item_type == 'context_external_tool') {
        var item_data = {
          'item[type]': item_type,
          'item[id]': $("#context_external_tools_select .tools .tool.selected").data('id'),
          'item[new_tab]': $("#external_tool_create_new_tab").attr('checked') ? '1' : '0',
          'item[indent]': $("#content_tag_indent").val()
        }
        item_data['item[url]'] = $("#external_tool_create_url").val();
        item_data['item[title]'] = $("#external_tool_create_title").val();
        $dialog.find('.alert-error').remove();
        if (item_data['item[url]'] === '') {
          var $errorBox = $('<div />', { 'class': 'alert alert-error', role: 'alert' }).css({marginTop: 8 });
          $errorBox.text(I18n.t('errors.external_tool_url', "An external tool can't be saved without a URL."));
          $dialog.prepend($errorBox);
        } else {
          submit(item_data);
        }
      } else if(item_type == 'context_module_sub_header') {
        var item_data = {
          'item[type]': item_type,
          'item[id]': $("#select_context_content_dialog .module_item_option:visible:first .module_item_select").val(),
          'item[indent]': $("#content_tag_indent").val()
        }
        item_data['item[title]'] = $("#sub_header_title").val();
        submit(item_data);
      } else {
        var $options = $("#select_context_content_dialog .module_item_option:visible:first .module_item_select option:selected");
        $options.each(function() {
          var $option = $(this);
          var item_data = {
            'item[type]': item_type,
            'item[id]': $option.val(),
            'item[title]': $option.text(),
            'item[indent]': $("#content_tag_indent").val()
          }
          if(item_data['item[id]'] == 'new') {
            $("#select_context_content_dialog").loadingImage();
            var url = $("#select_context_content_dialog .module_item_option:visible:first .new .add_item_url").attr('href');
            var data = $("#select_context_content_dialog .module_item_option:visible:first").getFormData();
            var callback = function(data) {
              var obj;

              // discussion_topics will come from real api v1 and so wont be nested behind a `discussion_topic` root object
              if (item_data['item[type]'] === 'discussion_topic') {
                obj = data;
              } else {
                obj = data[item_data['item[type]']]; // e.g. data['wiki_page'] for wiki pages
              }

              $("#select_context_content_dialog").loadingImage('remove');
              item_data['item[id]'] = obj.id;
              item_data['item[title]'] = $("#select_context_content_dialog .module_item_option:visible:first .item_title").val();
              item_data['item[title]'] = item_data['item[title]'] || obj.display_name
              var $option = $(document.createElement('option'));
              $option.val(obj.id).text(item_data['item[title]']);
              $("#" + item_data['item[type]'] + "s_select").find(".module_item_select option:last").before($option);
              submit(item_data);
            };
            if(item_data['item[type]'] == 'attachment') {
              $.ajaxJSONFiles(url, 'POST', data, $("#module_attachment_uploaded_data"), function(data) {
                callback(data);
              }, function(data) {
                $("#select_context_content_dialog").loadingImage('remove');
                $("#select_context_content_dialog").errorBox(I18n.t('errors.failed_to_create_item', 'Failed to Create new Item'));
              });
            } else {
              $.ajaxJSON(url, 'POST', data, function(data) {
                callback(data);
              }, function(data) {
                $("#select_context_content_dialog").loadingImage('remove');
                $("#select_context_content_dialog").errorBox(I18n.t('errors.failed_to_create_item', 'Failed to Create new Item'));
              });
            }
          } else {
            submit(item_data);
          }
        });
      }
    });
    $("#context_external_tools_select .tools").delegate('.tool', 'click', function() {
      var $tool = $(this);
      if($(this).hasClass('selected') && !$(this).hasClass('resource_selection')) {
        $(this).removeClass('selected');
        return;
      }
      $tool.parents(".tools").find(".tool.selected").removeClass('selected');
      $tool.addClass('selected');
      if($tool.hasClass('resource_selection')) {
        var tool = $tool.data('tool');
        var frameHeight = Math.max(Math.min($(window).height() - 100, 550), 100);
        var width = tool.resource_selection_settings.selection_width;
        var height = tool.resource_selection_settings.selection_height;
        var $dialog = $("#resource_selection_dialog");
        if($dialog.length == 0) {
          $dialog = $("<div/>", {id: 'resource_selection_dialog', style: 'padding: 0; overflow-y: hidden;'});
          $dialog.append($("<iframe/>", {id: 'resource_selection_iframe', style: 'width: 800px; height: ' + frameHeight + 'px; border: 0;', src: '/images/ajax-loader-medium-444.gif', borderstyle: '0'}));
          $("body").append($dialog.hide());
          $dialog
            .dialog({
              autoOpen: false,
              width: 'auto',
              resizable: true,
              close: function() {
                $dialog.find("iframe").attr('src', '/images/ajax-loader-medium-444.gif');
              },
              title: I18n.t('link_from_external_tool', "Link Resource from External Tool")
            })
            .bind('dialogresize', function() {
              $(this).find('iframe').add('.fix_for_resizing_over_iframe').height($(this).height()).width($(this).width());
            })
            .bind('dialogresizestop', function() {
              $(".fix_for_resizing_over_iframe").remove();
            })
            .bind('dialogresizestart', function() {
              $(this).find('iframe').each(function(){
                $('<div class="fix_for_resizing_over_iframe" style="background: #fff;"></div>')
                  .css({
                    width: this.offsetWidth+"px", height: this.offsetHeight+"px",
                    position: "absolute", opacity: "0.001", zIndex: 10000000
                  })
                  .css($(this).offset())
                  .appendTo("body");
              });
            })
            .bind('selection', function(event, data) {
              if(data.embed_type == 'basic_lti' && data.url) {
                $("#external_tool_create_url").val(data.url);
                $("#external_tool_create_title").val(data.text || tool.name);
                $("#context_external_tools_select .domain_message").hide();
              } else {
                alert(I18n.t('invalid_lti_resource_selection', "There was a problem retrieving a valid link from the external tool"));
                $("#external_tool_create_url").val('');
                $("#external_tool_create_title").val('');
              }
              $("#resource_selection_dialog iframe").attr('src', 'about:blank');
              $("#resource_selection_dialog").dialog('close');
            });
        }
        $dialog.dialog('close')
          .dialog('option', 'width', width || 800)
          .dialog('option', 'height', height || frameHeight || 400)
          .dialog('open');
        $dialog.triggerHandler('dialogresize');
        var url = $.replaceTags($("#select_content_resource_selection_url").attr('href'), 'id', tool.id);
        $dialog.find("iframe").attr('src', url);
      } else {
        $("#external_tool_create_url").val($tool.data('url') || '');
        $("#context_external_tools_select .domain_message").showIf($tool.data('domain'))
          .find(".domain").text($tool.data('domain'));
        $("#external_tool_create_title").val($tool.data('name'));
      }
    });
    var $tool_template = $("#context_external_tools_select .tools .tool:first").detach();
  });
});
