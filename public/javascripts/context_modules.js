/**
 * Copyright (C) 2012 Instructure, Inc.
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
  'i18n!context_modules',
  'jquery' /* $ */,
  'compiled/views/context_modules/context_modules', /* handles the publish/unpublish state */
  'jquery.ajaxJSON' /* ajaxJSON */,
  'jquery.instructure_date_and_time' /* parseFromISO, time_field, datetime_field */,
  'jquery.instructure_forms' /* formSubmit, fillFormData, formErrors, errorBox */,
  'jqueryui/dialog',
  'compiled/jquery/fixDialogButtons' /* fix dialog formatting */,
  'jquery.instructure_misc_helpers' /* /\$\.underscore/ */,
  'jquery.instructure_misc_plugins' /* .dim, confirmDelete, fragmentChange, showIf */,
  'jquery.keycodes' /* keycodes */,
  'jquery.loadingImg' /* loadingImage */,
  'jquery.templateData' /* fillTemplateData, getTemplateData */,
  'vendor/date' /* Date.parse */,
  'vendor/jquery.scrollTo' /* /\.scrollTo/ */,
  'vendor/ui.selectmenu',
  'jqueryui/sortable' /* /\.sortable/ */
], function(INST, I18n, $, ContextModulesView) {

  // TODO: AMD don't export global, use as module
  window.modules = (function() {
    return {
      updateTaggedItems: function() {
      },
      currentIndent: function($item) {
        var classes = $item.attr('class').split(/\s/);
        var indent = 0;
        for (idx = 0; idx < classes.length; idx++) {
          if(classes[idx].match(/^indent_/)) {
            var new_indent = parseInt(classes[idx].substring(7), 10);
            if(!isNaN(new_indent)) {
              indent = new_indent;
            }
          }
        }
        return indent;
      },
      refreshProgressions: function(show_links) {
        $("#context_modules .context_module:visible").each(function() {
          var $module = $(this);
          var id = $module.find(".header").getTemplateData({textValues: ['id']});
          var data = {progression_complete_count: 0, progression_started_count: 0};
          $("#progression_list .progression_" + id).each(function() {
            var state = $(this).getTemplateData({textValues: ['workflow_state']}).workflow_state;
            if(state == 'completed') {
              data.progression_complete_count++;
            } else if(state == 'unlocked' || state == 'started') {
              data.progression_started_count++;
            }
          });
          $module.find(".progression_details_link").showIf(data.progression_complete_count || data.progression_started_count);
          $module.find(".footer").fillTemplateData({data: data})
            .find(".progression_details_link").showIf(data.progression_complete_count || data.progression_started_count).end()
            .find(".progression_complete").showIf(data.progression_complete_count > 0).end()
            .find(".progression_started").showIf(data.progression_started_count > 0);
        });

        $(".context_module .progression_complete").showIf($(".context_module .prerequisites_footer:visible,.context_module_item .criterion img.not_blank").length > 0);
        if(show_links) {
          $(".loading_module_progressions_link").remove();
          $(".module_progressions_link").showIf($(".editable_context_module").length > 0 || $(".context_module .progression_complete:visible").length > 0 || $(".context_module_item.completed_item").length > 0);
        }
      },
      updateProgressions: function(user_id, callback) {
        var url = $(".progression_list_url").attr('href');
        if(user_id) {
          url = url + "?user_id=" + user_id;
        }
        if($(".context_module_item.progression_requirement:visible").length > 0) {
          $(".loading_module_progressions_link").show().attr('disabled', true);
        }
        $.ajaxJSON(url, 'GET', {}, function(data) {
          $(".loading_module_progressions_link").remove();
          if(!user_id) {
            $("#progression_list .student .progressions").empty();
          } else {
            $("#progression_list .student_" + user_id + " .progressions").empty();
          }
          var current_user_id = $("#identity .user_id").text();
          var $list_blank = $("#progression_list_blank");
          var $user_progression_list = $("#current_user_progression_list");
          var $student_progression_list = $("#progression_list");
          var lists_per_user = {};
          var progressions = [];
          for(var idx in data) {
            progressions.push(data[idx]);
          };
          var progressionsFinished = function() {
            if(!$("#context_modules").hasClass('editable')) {
              $("#context_modules .context_module").each(function() {
                modules.updateProgressionState($(this));
              });
            }
            modules.refreshProgressions(!user_id);
            if(callback) { callback(); }
          }
          var progressionCnt = 0;
          var nextProgression = function() {
            var data = progressions.shift();
            if(!data) {
              progressionsFinished();
              return;
            }
            var progression = data.context_module_progression;
            if(progression.user_id == current_user_id) {
              var $user_progression = $user_progression_list.find(".progression_" + progression.context_module_id)

              if($user_progression.length === 0 && $user_progression_list.length > 0) {
                $user_progression = $user_progression_list.find(".progression_blank").clone(true);
                $user_progression.removeClass('progression_blank').addClass('progression_' + progression.context_module_id);
                $user_progression_list.append($user_progression);
              }
              if($user_progression.length > 0) {
                progression.requirements_met = $.map(progression.requirements_met || [], function(r) { return r.id }).join(",");
                $user_progression.fillTemplateData({data: progression});
              }
            }
            var $progression = $list_blank.clone(true).removeAttr('id');
            $progression.fillTemplateData({data: progression});
            $progression.addClass('progression_' + progression.context_module_id);
            $progression.data('progression', progression);
            var $list_for_user = lists_per_user[progression.user_id];
            if(!$list_for_user) {
              $list_for_user = $student_progression_list.find(".student_" + progression.user_id + " .progressions");
              lists_per_user[progression.user_id] = $list_for_user;
            }
            $list_for_user.append($progression);
            if(progression.workflow_state == 'unlocked' || progression.workflow_state == 'started') {
              if(!lists_per_user[progression.user_id].found) {
                lists_per_user[progression.user_id].found = true
                $list_for_user.parents(".student").fillTemplateData({
                  data: {current_module: $("#context_module_" + progression.context_module_id + " .header .name").text() }
                });
              }
            }
            progressionCnt++;
            if(progressionCnt >= 50) {
              progressionCnt = 0;
              setTimeout(nextProgression, 150);
            } else {
              nextProgression();
            }
          }
          nextProgression();
        }, function() {
          if(callback) { callback(); }
        });
      },
      updateAssignmentData: function() {
        $.ajaxJSON($(".assignment_info_url").attr('href'), 'GET', {}, function(data) {
          $.each(data, function(id, info) {
            var data = {};
            if (info["points_possible"] != null) {
              data["points_possible_display"] = I18n.t('points_possible_short', '%{points} pts', { 'points': "<span class='points_possible_block'>" + info["points_possible"] + "</span>" });
            }
            if (info["due_date"] != null) {
              data["due_date_display"] = $.parseFromISO(info["due_date"]).date_formatted
            } else if (info["due_dates"] != null) {
              data["due_date_display"] = I18n.t('multiple_due_dates', 'Multiple Due Dates');
            }
            $("#context_module_item_" + id).fillTemplateData({data: data, htmlValues: ['points_possible_display']})
          });
        }, function() {
        });
      },
      itemClass: function(content_tag) {
        return content_tag.content_type + "_" + content_tag.content_id;
      },
      updateAllItemInstances: function(content_tag) {
        $(".context_module_item."+modules.itemClass(content_tag)+" .title").each(function() {
          $(this).text(content_tag.title);
        });
      },
      editModule: function($module) {
        var $form = $("#add_context_module_form");
        $form.data('current_module', $module);
        var data = $module.getTemplateData({textValues: ['name', 'unlock_at', 'require_sequential_progress']});
        $form.fillFormData(data, {object_name: 'context_module'});
        var isNew = false;
        if($module.attr('id') == 'context_module_new') {
          isNew = true;
          $form.attr('action', $form.find(".add_context_module_url").attr('href'));
          $form.find(".completion_entry").hide();
          $form.attr('method', 'POST');
          $form.find(".submit_button").text(I18n.t('buttons.add', "Add Module"));
        } else {
          $form.attr('action', $module.find(".edit_module_link").attr('href'));
          $form.find(".completion_entry").show();
          $form.attr('method', 'PUT');
          $form.find(".submit_button").text(I18n.t('buttons.update', "Update Module"));
        }
        $form.find("#unlock_module_at").prop('checked', data.unlock_at);
        $form.find("#require_sequential_progress").attr('checked', data.require_sequential_progress == "true" || data.require_sequential_progress == "1");
        $form.find(".prerequisites_entry").showIf($("#context_modules .context_module").length > 1);
        var prerequisites = [];
        $module.find(".prerequisites .criterion").each(function() {
          prerequisites.push($(this).getTemplateData({textValues: ['id', 'name', 'type']}));
        });
        $form.find(".prerequisites_list .criteria_list").empty();
        for(var idx in prerequisites) {
          var pre = prerequisites[idx];
          $form.find(".add_prerequisite_link:first").click();
          if(pre.type == 'context_module') {
            $form.find(".prerequisites_list .criteria_list .criterion:last select").val(pre.id);
          }
        }
        $form.find(".completion_criteria_list .criteria_list").empty();
        $module.find(".content .context_module_item .criterion.defined").each(function() {
          var data = $(this).parents(".context_module_item").getTemplateData({textValues: ['id', 'criterion_type', 'min_score']});
          $form.find(".add_completion_criterion_link").click();
          $form.find(".completion_criteria_list .criteria_list .criterion:last")
            .find(".id").val(data.id || "").change().end()
            .find(".type").val(data.criterion_type || "").change().end()
            .find(".min_score").val(data.min_score || "");
        });
        var no_prereqs = $("#context_modules .context_module").length == 1;
        var no_items = $module.find(".content .context_module_item").length === 0;
        $form.find(".prerequisites_list .no_prerequisites_message").showIf(prerequisites.length === 0).end()
          .find(".prerequisites_list .criteria_list").showIf(prerequisites.length != 0).end()
          .find(".add_prerequisite_link").showIf(!no_prereqs).end()
          .find(".completion_criteria_list .no_items_message").showIf(no_items).end()
          .find(".completion_criteria_list .no_criteria_message").showIf(!no_items && $module.find(".content .context_module_item .criterion.defined").length === 0).end()
          .find(".completion_criteria_list .criteria_list").showIf(!no_items).end()
          .find(".add_completion_criterion_link").showIf(!no_items);
        $module.fadeIn('fast', function() {
        });
        $module.addClass('dont_remove');
        $form.find(".module_name").toggleClass('lonely_entry', isNew);
        $form.dialog({
          autoOpen: false,
          modal: true,
          width: 600,
          close: function() {
            modules.hideEditModule(true);
          }
        }).fixDialogButtons().dialog('option', {title: (isNew ? I18n.t('titles.add', "Add Module") : I18n.t('titles.edit', "Edit Module Settings")), width: (isNew ? 'auto' : 600)}).dialog('open'); //show();
        $module.removeClass('dont_remove');
        $form.find(":text:visible:first").focus().select();
      },
      hideEditModule: function(remove) {
        var $module = $("#add_context_module_form").data('current_module'); //.parents(".context_module");
        if(remove && $module && $module.attr('id') == 'context_module_new' && !$module.hasClass('dont_remove')) {
          $module.remove();
        }
        $("#add_context_module_form:visible").dialog('close');
      },
      addItemToModule: function($module, data) {
        if(!data) { return $("<div/>"); }
        data.id = data.id || 'new'
        data.type = data.type || data['item[type]'] || $.underscore(data.content_type);
        data.title = data.title || data['item[title]'];
        data.new_tab = data.new_tab ? '1' : '0';
        var $item, $olditem = (data.id != 'new') ? $("#context_module_item_" + data.id) : [];
        if($olditem.length) {
          $item = $olditem.clone(true).removeAttr('id');
          $olditem.remove();
        } else {
          $item = $("#context_module_item_blank").clone(true).removeAttr('id');
        }
        $item.addClass(data.type + "_" + data.id);
        $item.addClass(data.type);
        $item.fillTemplateData({
          data: data,
          id: 'context_module_item_' + data.id,
          hrefValues: ['id', 'context_module_id']
        });
        for(var idx = 0; idx < 10; idx++) {
          $item.removeClass('indent_' + idx);
        }
        $item.addClass('indent_' + (data.indent || 0));
        $item.addClass(modules.itemClass(data));
        // don't just tack onto the bottom, put it in its correct position
        var $before = null;
        $module.find(".context_module_items").children().each(function() {
          var position = parseInt($(this).getTemplateData({textValues: ['position']}).position, 10);
          if((data.position || data.position === 0) && (position || position === 0)) {
            if($before == null && (position - data.position >= 0)) {
              $before = $(this);
            }
          }
        });
        if(!$before) {
          $module.find(".context_module_items").append($item.show());
        } else {
          $before.before($item.show());
        }
        return $item;
      },
      refreshModuleList: function() {
        $("#module_list").find(".context_module_option").remove();
        $("#context_modules .context_module").each(function() {
          var data = $(this).find(".header").getTemplateData({textValues: ['name', 'id']});
          var $option = $(document.createElement('option'));
          $option.val(data.id);

          // data.id could come back as undefined, so calling $option.val(data.id) would return an "", which is not chainable, so $option.val(data.id).text... would die.
          $option.attr('role', 'option')
            .text(data.name) // TODO: I18n
            //.text("the module, " + data.name)
            .addClass('context_module_' + data.id)
            .addClass('context_module_option');

          $("#module_list").append($option);
        });
      },
      filterPrerequisites: function($module, prerequisites) {
        var list = modules.prerequisites();
        var id = $module.attr('id').substring('context_module_'.length);
        var res = [];
        for(var idx in prerequisites) {
          if($.inArray(prerequisites[idx], list[id]) == -1) {
            res.push(prerequisites[idx]);
          }
        }
        return res;
      },
      prerequisites: function() {
        var result = {
          to_visit: {},
          visited: {}
        };
        $("#context_modules .context_module").each(function() {
          var id = $(this).attr('id').substring('context_module_'.length);
          result[id] = [];
          $(this).find(".prerequisites .criterion").each(function() {
            var pre_id = $(this).getTemplateData({textValues: ['id']}).id;
            if($(this).hasClass('context_module_criterion')) {
              result[id].push(pre_id);
              result.to_visit[id + "_" + pre_id] = true;
            }
          });
        });

        for (var val in result.to_visit) {
          if (result.to_visit.hasOwnProperty(val)) {
            var ids = val.split("_");
            if ( result.visited[val] ) {
              continue;
            }
            result.visited[val] = true;
            for(var jdx in result[ids[1]]) {
              result[ids[0]].push(result[ids[1]][jdx]);
              result.to_visit[ids[0] + "_" + result[ids[1]][jdx]] = true;
            }
          }
        }
        delete result['to_visit'];
        delete result['visited'];
        return result;
      },
      updateProgressionState: function($module) {
        var id = $module.attr('id').substring(15);
        var $progression = $("#current_user_progression_list .progression_" + id);
        var data = $progression.getTemplateData({textValues: ['context_module_id', 'workflow_state', 'requirements_met', 'collapsed', 'current_position']});
        var $module = $("#context_module_" + data.context_module_id);
        $module.toggleClass('completed', data.workflow_state == 'completed');
        var progression_state = data.workflow_state
        if(progression_state == "unlocked" || progression_state == "started") { progression_state = "in progress"; }
        if (progression_state == "completed" && !$module.find(".progression_requirement").length) {
          // this means that there were no requirements so even though the workflow_state says completed, dont show "completed" because there really wasnt anything to complete
          progression_state = "";
        }
        $module.fillTemplateData({data: {progression_state: progression_state}});
        $module.toggleClass('locked_module', data.workflow_state == 'locked' && !$module.hasClass('editable_context_module'));
        $module.find(".context_module_item").each(function() {
          var position = parseInt($(this).getTemplateData({textValues: ['position']}).position, 10);
          if(data.current_position && position && data.current_position < position) {
            $(this).addClass('after_current_position');
          }
        });
        if(data.requirements_met) {
          var reqs = data.requirements_met.split(",");
          for(var idx in reqs) {
            var req = reqs[idx];
            $module.find("#context_module_item_" + req).addClass('completed_item');
          }
        }
        if(data.collapsed == 'true') {
          $module.addClass('collapsed_module');
        }
      },
      sortable_module_options: {
        connectWith: '.context_module_items',
        handle: '.move_item_link',
        helper: 'clone',
        placeholder: 'context_module_placeholder',
        forcePlaceholderSize: true,
        axis: 'y',
        containment: "#context_modules",
        update: function(event, ui) {
          var $module = ui.item.parents(".context_module");
          var url = $module.find(".reorder_items_url").attr('href');
          $module.find(".content").loadingImage();
          var items = [];
          $module.find(".context_module_items .context_module_item").each(function() {
            items.push($(this).getTemplateData({textValues: ['id']}).id);
          });
          $.ajaxJSON(url, 'POST', {order: items.join(",")}, function(data) {
            $module.find(".content").loadingImage('remove');
            if(data && data.context_module && data.context_module.content_tags) {
              for(var idx in data.context_module.content_tags) {
                var tag = data.context_module.content_tags[idx].content_tag;
                $module.find("#context_module_item_" + tag.id).fillTemplateData({
                  data: {position: tag.position}
                });
              }
            }
          }, function(data) {
            $module.find(".content").loadingImage('remove');
            $module.find(".content").errorBox(I18n.t('errors.reorder', 'Reorder failed, please try again.'));
          });
        }
      }
    };
  })();


  modules.initModuleManagement = function() {
    // Create the context modules backbone view to manage the publish button. 
    var context_modules_view = new ContextModulesView({
      el: $("#content")
    });

    $("#unlock_module_at").change(function() {
      $this = $(this);
      $unlock_module_at_details = $(".unlock_module_at_details");
      $unlock_module_at_details.showIf($this.attr('checked'))

      if (!$this.attr('checked')) {
        $("#context_module_unlock_at").val('').triggerHandler('change');
      }
    }).triggerHandler('change');

    // -------- BINDING THE UPDATE EVENT -----------------
    $(".context_module").bind('update', function(event, data) {
      data.context_module.unlock_at = $.parseFromISO(data.context_module.unlock_at).datetime_formatted;
      var $module = $("#context_module_" + data.context_module.id);
      $module.find(".header").fillTemplateData({
        data: data.context_module,
        hrefValues: ['id']
      });

      $module.find(".footer").fillTemplateData({
        data: data.context_module,
        hrefValues: ['id']
      });

      $module.find(".unlock_details").showIf(data.context_module.unlock_at && Date.parse(data.context_module.unlock_at) > new Date());
      $module.find(".footer .prerequisites").empty();

      for(var idx in data.context_module.prerequisites) {
        var pre = data.context_module.prerequisites[idx];
        var $pre = $("#display_criterion_blank").clone(true).removeAttr('id');
        $pre.fillTemplateData({data: pre});
        $module.find(".footer .prerequisites").append($pre.show());
      }

      $module.find(".context_module_items .context_module_item")
        .removeClass('progression_requirement')
        .removeClass('min_score_requirement')
        .removeClass('max_score_requirement')
        .removeClass('must_view_requirement')
        .removeClass('must_submit_requirement')
        .removeClass('must_contribute_requirement')
        .find('.criterion').removeClass('defined');

      for(var idx in data.context_module.completion_requirements) {
        var req = data.context_module.completion_requirements[idx];
        req.criterion_type = req.type;
        var $item = $module.find("#context_module_item_" + req.id);
        $item.find(".criterion").fillTemplateData({data: req});
        $item.find(".completion_requirement").fillTemplateData({data: req});
        $item.find(".criterion").addClass('defined');
        $item.addClass(req.type + "_requirement").addClass('progression_requirement');
      }

      $module.find(".prerequisites_footer").showIf(data.context_module.prerequisites && data.context_module.prerequisites.length > 0);
      modules.refreshModuleList();
    });

    $("#add_context_module_form").formSubmit({
      object_name: 'context_module',
      processData: function(data) {
        var prereqs = [];
        $(this).find(".prerequisites_list .criteria_list .criterion").each(function() {
          var id = $(this).find(".option select").val();
          if(id) {
            prereqs.push("module_" + id);
          }
        });
        data['context_module[prerequisites]'] = prereqs.join(",");
        data['context_module[completion_requirements][none]'] = "none";
        $(this).find(".completion_criteria_list .criteria_list .criterion").each(function() {
          var id = $(this).find(".id").val();
          data["context_module[completion_requirements][" + id + "][type]"] = $(this).find(".type").val();
          data["context_module[completion_requirements][" + id + "][min_score]"] = $(this).find(".min_score").val();
        });
        return data;
      },
      beforeSubmit: function(data) {
        var $module = $(this).data('current_module');
        $module.loadingImage();
        $module.find(".header").fillTemplateData({
          data: data
        });
        $module.addClass('dont_remove');
        modules.hideEditModule();
        $module.removeClass('dont_remove');
        return $module;
      },
      success: function(data, $module) {
        $module.loadingImage('remove');
        $module.attr('id', 'context_module_' + data.context_module.id);

        // Set this module up with correct data attributes
        $module.data('module-url', "/courses/" + data.context_module.context_id + "/modules/" + data.context_module.id);
        $module.data('workflow-state', data.context_module.workflow_state);
        if(data.context_module.workflow_state == "unpublished"){
          $module.find('.workflow-state-action').text("Publish");
          $module.find('.workflow-state-icon').addClass('publish-module-link')
                                              .removeClass('unpublish-module-link');
          $module.addClass('unpublished_module');
        }

        $("#no_context_modules_message").slideUp();
        $module.triggerHandler('update', data);
      },
      error: function(data, $module) {
        $module.loadingImage('remove');
      }
    });

    $("#add_context_module_form .add_prerequisite_link").click(function(event) {
      event.preventDefault();
      var $form = $(this).parents("#add_context_module_form");
      var $module = $form.data('current_module');
      var $select = $("#module_list").clone(true).removeAttr('id');
      var $pre = $form.find("#criterion_blank").clone(true).removeAttr('id');
      $select.find("." + $module.attr('id')).remove();
      var afters = [];

      $("#context_modules .context_module").each(function() {
        if($(this)[0] == $module[0] || afters.length > 0) {
          afters.push($(this).getTemplateData({textValues: ['id']}).id);
        }
      });

      for(var idx in afters) {
        $select.find(".context_module_" + afters[idx]).attr('disabled', true);
      }

      $pre.find(".option").empty().append($select.show());
      $form.find(".prerequisites_list .criteria_list").append($pre).show();
      $pre.slideDown();
      $form.find(".no_prerequisites_message").hide();
      $select.focus();
    });

    $("#add_context_module_form .add_completion_criterion_link").click(function(event) {
      event.preventDefault();
      var $form = $(this).parents("#add_context_module_form");
      var $module = $form.data('current_module');
      var $option = $("#completion_criterion_option").clone(true).removeAttr('id');
      var $select = $option.find("select.id");
      var $pre = $form.find("#criterion_blank").clone(true).removeAttr('id');
      $pre.find(".prereq_desc").remove();
      var prereqs = modules.prerequisites();
      var $optgroups = {};
      $module.find(".content .context_module_item").not('.context_module_sub_header').each(function() {
        var data = $(this).getTemplateData({textValues: ['id', 'title', 'type']});
        if (data.type == 'assignment') {
          displayType = I18n.t('optgroup.assignments', "Assignments");
        } else if (data.type == 'attachment') {
          displayType = I18n.t('optgroup.files', "Files");
        } else if (data.type == 'quiz') {
          displayType = I18n.t('optgroup.quizzes', "Quizzes");
        } else if (data.type == 'external_url') {
          displayType = I18n.t('optgroup.external_urls', "External URLs");
        } else if (data.type == 'context_external_tool') {
          displayType = I18n.t('optgroup.external_tools', "External Tools");
        } else if (data.type == 'discussion_topic') {
          displayType = I18n.t('optgroup.discussion_topics', "Discussions");
        } else if (data.type == 'wiki_page') {
          displayType = I18n.t('optgroup.wiki_pages', "Wiki Pages");
        }
        var group = $optgroups[displayType]
        if (!group) {
          group = $optgroups[displayType] = $(document.createElement('optgroup'))
          group.attr('label', displayType)
          $select.append(group)
        }
        var titleDesc = data.title;
        var $option = $(document.createElement('option'));
        $option.val(data.id).text(titleDesc);
        group.append($option);
      });
      $pre.find(".option").empty().append($option);
      $option.slideDown();
      $form.find(".completion_criteria_list .criteria_list").append($pre).show();
      $pre.slideDown();
      $form.find(".no_criteria_message").hide();
      $select.change().focus();
    });
    $("#completion_criterion_option .id").change(function() {
      var $option = $(this).parents(".completion_criterion_option");
      var data = $("#context_module_item_" + $(this).val()).getTemplateData({textValues: ['type']});
      $option.find(".type option").hide().attr('disabled', true).end()
        .find(".type option.any").show().attr('disabled', false).end()
        .find(".type option." + data.type).show().attr('disabled', false);
      $option.find(".type").val($option.find(".type option." + data.criterion_type + ":first").val())
      $option.find(".type").change();
    });
    $("#completion_criterion_option .type").change(function() {
      var $option = $(this).parents(".completion_criterion_option");
      $option.find(".min_score_box").showIf($(this).val() == 'min_score');
      var id = $option.find(".id").val();
      var points_possible = $.trim($("#context_module_item_" + id + " .points_possible").text()) ||
          // for some reason the previous did not have anything in it sometimes (noticed when you are dealing with a newly added module)
          $.trim($("#context_module_item_" + id + " .points_possible_block").text());
      if(points_possible.length > 0) {
        $option.find(".points_possible").text(points_possible);
        $option.find(".points_possible_parent").show();
      } else {
        $option.find(".points_possible_parent").hide();
      }
    });
    $("#add_context_module_form .delete_criterion_link").click(function(event) {
      event.preventDefault();
      $(this).parents(".criterion").slideUp(function() {
        $(this).remove();
      });
    });
    $(".delete_module_link").live('click', function(event) {
      event.preventDefault();
      $(this).parents(".context_module").confirmDelete({
        url: $(this).attr('href'),
        message: I18n.t('confirm.delete', "Are you sure you want to delete this module?"),
        success: function(data) {
          var id = data.context_module.id;
          $(".context_module .prerequisites .criterion").each(function() {
            var criterion = $(this).getTemplateData({textValues: ['id', 'type']});
            if(criterion.type == 'context_module' && criterion.id == id) {
              $(this).remove();
            }
          });
          $(this).slideUp(function() {
            $(this).remove();
            modules.updateTaggedItems();
          });
        }
      });
    });
    $(".outdent_item_link,.indent_item_link").live('click', function(event) {
      event.preventDefault();
      var do_indent = $(this).hasClass('indent_item_link');
      var $item = $(this).parents(".context_module_item");
      var indent = modules.currentIndent($item);
      indent = Math.max(Math.min(indent + (do_indent ? 1 : -1), 5), 0);
      $item.loadingImage({image_size: 'small'});
      $.ajaxJSON($(this).attr('href'), "PUT", {'content_tag[indent]': indent}, function(data) {
        $item.loadingImage('remove');
        var $module = $("#context_module_" + data.content_tag.context_module_id);
        modules.addItemToModule($module, data.content_tag);
        $module.find(".context_module_items.ui-sortable").sortable('refresh');
        modules.updateAssignmentData();
      }, function(data) {
      });
    });
    $(".edit_item_link").live('click', function(event) {
      event.preventDefault();
      var $item = $(this).parents(".context_module_item");
      var data = $item.getTemplateData({textValues: ['title', 'url', 'indent', 'new_tab']});
      data.indent = modules.currentIndent($item);
      $("#edit_item_form").find(".external_url").showIf($item.hasClass('external_url') || $item.hasClass('context_external_tool'));
      $("#edit_item_form").find(".external_tool").showIf($item.hasClass('context_external_tool'));
      $("#edit_item_form").attr('action', $(this).attr('href'));
      $("#edit_item_form").fillFormData(data, {object_name: 'content_tag'});
      $("#edit_item_form").dialog({
        title: I18n.t('titles.edit_item', "Edit Item Details")
      }).fixDialogButtons();
    });
    $("#edit_item_form .cancel_button").click(function(event) {
      $("#edit_item_form").dialog('close');
    });
    $("#edit_item_form").formSubmit({
      beforeSubmit: function(data) {
        $(this).loadingImage();
      },
      success: function(data) {
        $(this).loadingImage('remove');
        var $module = $("#context_module_" + data.content_tag.context_module_id);
        var $item = modules.addItemToModule($module, data.content_tag);
        $module.find(".context_module_items.ui-sortable").sortable('refresh');
        if (data.content_tag.content_id != 0) {
          modules.updateAllItemInstances(data.content_tag);
        }
        modules.updateAssignmentData();
        $(this).dialog('close');
      },
      error: function(data) {
        $(this).loadingImage('remove');
        $(this).formErrors(data);
      }
    });
    $(".delete_item_link").live('click', function(event) {
      event.preventDefault();
      $(this).parents(".context_module_item").confirmDelete({
        url: $(this).attr('href'),
        message: I18n.t('confirm.delete_item', 'Are you sure you want to remove this item from the module?'),
        success: function(data) {
          $(this).slideUp(function() {
            $(this).remove();
            modules.updateTaggedItems();
          });
        }
      });
    });

    $(".edit_module_link").live('click', function(event) {
      event.preventDefault();
      modules.editModule($(this).parents(".context_module"));
    });

    $(".add_module_link").live('click', function(event) {
      event.preventDefault();
      var $module = $("#context_module_blank").clone(true).attr('id', 'context_module_new');
      $("#context_modules").append($module);
      var $select = $module.find(".context-module-toolbar-item select")

      // init appended moudule
      $select.selectmenu({
        menuWidth: 140,
        maxHeight: 300,
        positionOptions: {
          of: $select.parents('.context-module-toolbar-item'),
          at: 'center bottom',
          my: 'center bottom-30'
        },
        close: function(e, object){
          $(this).selectmenu("index", 0)
        }
      })
      .next('span').hide()
      
      $module.find(".context_module_items").sortable(modules.sortable_module_options);
      $("#context_modules.ui-sortable").sortable('refresh');
      $("#context_modules .context_module .context_module_items.ui-sortable").each(function() {
        $(this).sortable('refresh');
        $(this).sortable('option', 'connectWith', '.context_module_items');
      });
      modules.editModule($module);
    });

    function conveyrToDialog($module){
      if($module.hasClass('collapsed_module')) {
        $module.find(".expand_module_link").triggerHandler('click', function() {
          $module.find(".add_module_item_link").click();
        });
        return;
      }
      if(INST && INST.selectContentDialog) {
        var module = $module.find(".header").getTemplateData({textValues: ['name', 'id']});
        var options = {for_modules: true};
        options.type = $module.find("select.add_module_item_select").val();
        options.select_button_text = I18n.t('buttons.add_item', "Add Item");
        options.holder_name = module.name;
        options.dialog_title = I18n.t('titles.add_item', "Add Item to %{module}", {'module': module.name});

        options.submit = function(item_data) {
          var $module = $("#context_module_" + module.id);
          var $item = modules.addItemToModule($module, item_data);
          $module.find(".context_module_items.ui-sortable").sortable('refresh');

          // the url check
          var url = $module.find(".add_module_item_link").attr('rel');
          $item.loadingImage({image_size: 'small'});
          $.ajaxJSON(url, 'POST', item_data, function(data) {
            $item.loadingImage('remove');
            $item.remove();
            data.content_tag.type = item_data['item[type]'];
            modules.addItemToModule($module, data.content_tag);
            $module.find(".context_module_items.ui-sortable").sortable('refresh');
            modules.updateAssignmentData();

            jumpToUrl(data.content_tag)

          });
        };
        INST.selectContentDialog(options);
      }
    }

    function jumpToUrl( contentTag ){
      var courseId = contentTag.context_code.split('_')[1]
        contentId = contentTag.content_id,
		contentTitle = contentTag.title;

      switch (contentTag.type)
      {
        case 'quiz':
        window.location.href = '/courses/' + courseId + '/quizzes/' + contentId + '/edit'
        break;

        case 'discussion_topic':
        window.location.href = '/courses/' + courseId + '/discussion_topics/' + contentId
        break;

        case 'assignment':
        window.location.href = '/courses/' + courseId + '/assignments/' + contentId + '/edit'
        break;
		
	    case 'wiki_page':
	    window.location.href = '/courses/' + courseId + '/wiki/' + contentTitle + '?module_item_id=1#edit'
	    break;
		
      }
    }

    // prevent initiallizing the template "#context_module_blank" which contain 'select'
    $('#context_modules .context-module-toolbar-item select').each(function(){
      $(this)
      .selectmenu({
        menuWidth: 140,
        maxHeight: 300,
        positionOptions: {
          of: $(this).parents('.context-module-toolbar-item'),
          at: 'center bottom',
          my: 'center bottom-30'
        },
        close: function(e, object){
          $(this).selectmenu("index", 0)
        }
      })
      .next('span').hide()
    })

    $(".add_module_item_select").live( "change", function() {
      var $module = $(this).parents(".context_module");

      if($(this).val() == 'context_external_tool') {
        var $select = $("#context_external_tools_select");
        if(!$select.hasClass('loaded')) {
          $select.find(".message").text("Loading...");
          var url = $("#select_context_content_dialog .external_tools_url").attr('href');
          $.ajaxJSON(url, 'GET', {}, function(data) {
            $select.find(".message").remove();
            $select.addClass('loaded');
            $select.find(".tools").empty();
            for(var idx in data) {
              var tool = data[idx];
              if(tool.url || tool.domain || tool.resource_selection_settings) {
                var $tool = $tool_template.clone(true);
                $tool.toggleClass('resource_selection', !!tool.resource_selection_settings);
                $tool.fillTemplateData({
                  data: tool,
                  dataValues: ['id', 'url', 'domain', 'name']
                });
                $tool.data('tool', tool);
                $select.find(".tools").append($tool.show());
              }
            }
          }, function(data) {
            $select.find(".message").text(I18n.t('errors.loading_failed', "Loading Failed"));
          });
        }
      }

      conveyrToDialog($module)

    });

    $(".context-module-toolbar-item").on("click.fireSelectMenu", '.add_item_link', function(e) {
      e.preventDefault()
      e.stopPropagation()
      var $select = $(this).next(".add_module_item_select")

      if( $('.ui-selectmenu-open').size() !== 0 ){
        $('.ui-selectmenu-open').removeClass('ui-selectmenu-open')
      }

      $select.selectmenu("open")
      
    })

    // mousedown on document will trigger selectmenu close
    $(".context-module-toolbar-item").on("mousedown", '.add_item_link', function(e) {
      e.stopPropagation()
    })

    

    $("#add_module_prerequisite_dialog .cancel_button").click(function() {
      $("#add_module_prerequisite_dialog").dialog('close');
    });
    $(".delete_prerequisite_link").live('click', function(event) {
      event.preventDefault();
      var $criterion = $(this).parents(".criterion");
      var prereqs = []

      $(this).parents(".context_module .prerequisites .criterion").each(function() {
        if($(this)[0] != $criterion[0]) {
          var data = $(this).getTemplateData({textValues: ['id', 'type']});
          var type = data.type == "context_module" ? "module" : data.type;
          prereqs.push(type + "_" + data.id);
        }
      });

      var url = $(this).parents(".context_module").find(".edit_module_link").attr('href');
      var data = {'context_module[prerequisites]': prereqs.join(",")}

      $criterion.dim();

      $.ajaxJSON(url, 'PUT', data, function(data) {
        $("#context_module_" + data.context_module.id).triggerHandler('update', data);
      });
    });
    $("#add_module_prerequisite_dialog .submit_button").click(function() {
      var val = $("#add_module_prerequisite_dialog .prerequisite_module_select select").val();
      if(!val) { return; }
      $("#add_module_prerequisite_dialog").loadingImage();
      var prereqs = [];
      prereqs.push("module_" + val);
      var $module = $("#context_module_" + $("#add_module_prerequisite_dialog").getTemplateData({textValues: ['context_module_id']}).context_module_id);
      $module.find(".prerequisites .criterion").each(function() {
        prereqs.push("module_" + $(this).getTemplateData({textValues: ['id', 'name', 'type']}).id);
      });
      var url = $module.find(".edit_module_link").attr('href');
      var data = {'context_module[prerequisites]': prereqs.join(",")}
      $.ajaxJSON(url, 'PUT', data, function(data) {
        $("#add_module_prerequisite_dialog").loadingImage('remove');
        $("#add_module_prerequisite_dialog").dialog('close');
        $("#context_module_" + data.context_module.id).triggerHandler('update', data);
      }, function(data) {
        $("#add_module_prerequisite_dialog").loadingImage('remove');
        $("#add_module_prerequisite_dialog").formErrors(data);
      });
    });
    $(".context_module .add_prerequisite_link").live('click', function(event) {
      event.preventDefault();
      var module = $(this).parents(".context_module").find(".header").getTemplateData({textValues: ['name', 'id']});
      $("#add_module_prerequisite_dialog").fillTemplateData({
        data: {module_name: module.name, context_module_id: module.id}
      });
      var $module = $(this).parents(".context_module");
      var $select = $("#module_list").clone(true).removeAttr('id');
      $select.find("." + $module.attr('id')).remove();
      var afters = [];
      $("#context_modules .context_module").each(function() {
        if($(this)[0] == $module[0] || afters.length > 0) {
          afters.push($(this).getTemplateData({textValues: ['id']}).id);
        }
      });
      for(var idx in afters) {
        $select.find(".context_module_" + afters[idx]).attr('disabled', true);
      }
      $("#add_module_prerequisite_dialog").find(".prerequisite_module_select").empty().append($select.show());
      $("#add_module_prerequisite_dialog").dialog({
        title: I18n.t('titles.add_prerequisite', 'Add Prerequisite to %{module}', {'module': module.name}),
        width: 400
      });
    });
    $("#add_context_module_form .cancel_button").click(function(event) {
      modules.hideEditModule(true);
    });
    setTimeout(function() {
      var $items = [];
      $("#context_modules .context_module_items").each(function() {
        $items.push($(this));
      });
      var next = function() {
        if($items.length > 0) {
          var $item = $items.shift();
          $item.sortable(modules.sortable_module_options);
          setTimeout(next, 10);
        }
      };
      next();
      $("#context_modules").sortable({
        handle: '.reorder_module_link',
        helper: 'clone',
        containment: '#context_modules_sortable_container',
        axis: 'y',
        update: function(event, ui) {
          var ids = []
          $("#context_modules .context_module").each(function() {
            ids.push($(this).attr('id').substring('context_module_'.length));
          });
          var url = $(".reorder_modules_url").attr('href');
          $("#context_modules").loadingImage();
          $.ajaxJSON(url, 'POST', {order: ids.join(",")}, function(data) {
            $("#context_modules").loadingImage('remove');
            for(var idx in data) {
              var module = data[idx];
              $("#context_module_" + module.context_module.id).triggerHandler('update', module);
            }
          }, function(data) {
            $("#context_modules").loadingImage('remove');
          });
        }
      });
      modules.refreshModuleList();
      modules.refreshed = true;
    }, 1000);
  }

  $(document).ready(function() {
    $(".datetime_field").datetime_field();

    $(".context_module").live('mouseover', function() {
      $(".context_module_hover").removeClass('context_module_hover');
      $(this).addClass('context_module_hover');
    });

    $(".context_module_item").live('mouseover focus', function() {
      $(".context_module_item_hover").removeClass('context_module_item_hover');
      $(this).addClass('context_module_item_hover');
    });

    var $currentElem = null;
    var hover = function($elem) {

      if($elem.hasClass('context_module')) {
        $(".context_module_hover").removeClass('context_module_hover');
        $(".context_module_item_hover").removeClass('context_module_item_hover');
        $elem.addClass('context_module_hover');
      } else if($elem.hasClass('context_module_item')) {
        $(".context_module_item_hover").removeClass('context_module_item_hover');
        $(".context_module_hover").removeClass('context_module_hover');
        $elem.addClass('context_module_item_hover');
        $elem.parents(".context_module").addClass('context_module_hover');
      }
      $elem.find(":tabbable:first").focus();
    };
    $(document).keycodes('j k', function(event) {
      $currentElem = $(".context_module_hover:visible,.context_module_item_hover:visible").filter(":last");
      if($currentElem.length === 0) {
        $currentElem = $(".context_module:visible:first");
        hover($currentElem);
        return;
      }
      var method = "prev";
      var $elem = null;
      if(event.keyString == 'j') {
        if($currentElem.hasClass('context_module')) {
          $elem = $currentElem.find(".context_module_item:visible:first");
          if($elem.length === 0) {
            $elem = $currentElem.next(".context_module");
          }
        } else if($currentElem.hasClass('context_module_item')) {
          $elem = $currentElem.next(".context_module_item:visible");
          if($elem.length === 0) {
            $elem = $currentElem.parents(".context_module").next(".context_module");
          }
        }
      } else if(event.keyString == 'k') {
        if($currentElem.hasClass('context_module')) {
          $elem = $currentElem.prev(".context_module").find(".context_module_item:visible:last");
          if($elem.length === 0) {
            $elem = $currentElem.prev(".context_module");
          }
        } else if($currentElem.hasClass('context_module_item')) {
          $elem = $currentElem.prev(".context_module_item:visible");
          if($elem.length === 0) {
            $elem = $currentElem.parents(".context_module");
          }
        }
      }
      if($elem && $elem.length > 0) {
        $currentElem = $elem;
      }
      hover($currentElem);
    }).keycodes('e d i o', function(event) {
        if(!$currentElem || $currentElem.length === 0) {
          return;
        }
        if(event.keyString == 'e') {
          $currentElem.find(".edit_link:first:visible").click();
        } else if(event.keyString == 'd') {
          $currentElem.find(".delete_link:first:visible").click();
        } else if(event.keyString == 'i') {
          $currentElem.find(".indent_item_link:first:visible").click();
        } else if(event.keyString == 'o') {
          $currentElem.find(".outdent_item_link:first:visible").click();
        }
      }).keycodes('n', function(event) {
        if(event.keyString == 'n') {
          $(".add_module_list:visible:first").click();
        }
      });;
    if($(".context_module:first .content:visible").length == 0) {
      $("html,body").scrollTo($(".context_module .content:visible").filter(":first").parents(".context_module"));
    }
    if($("#context_modules").hasClass('editable')) {
      setTimeout(modules.initModuleManagement, 1000);
    }

    modules.updateProgressions();
    modules.refreshProgressions();
    modules.updateAssignmentData();

    $(".context_module").find(".expand_module_link,.collapse_module_link").bind('click', function(event, goSlow) {
      event.preventDefault();
      var expandCallback = null;
      if(goSlow && $.isFunction(goSlow)) {
        expandCallback = goSlow;
        goSlow = null;
      }
      var collapse = $(this).hasClass('collapse_module_link') ? '1' : '0';
      var $module = $(this).parents(".context_module");
      var reload_entries = $module.find(".content .context_module_items").children().length === 0;
      var toggle = function(show) {
        var callback = function() {
          $module.find(".collapse_module_link").showIf($module.find(".content:visible").length > 0);
          $module.find(".expand_module_link").showIf($module.find(".content:visible").length === 0);
          if($module.find(".content:visible").length > 0) {
            $module.find(".footer .manage_module").css('display', '');
            $module.toggleClass('collapsed_module', false);
          } else {
            $module.find(".footer .manage_module").css('display', ''); //'none');
            $module.toggleClass('collapsed_module', true);
          }
          if(expandCallback && $.isFunction(expandCallback)) {
            expandCallback();
          }
        };
        if(show) {
          $module.find(".content").show();
          callback();
        } else {
          $module.find(".content").slideToggle(callback);
        }
      }
      if(reload_entries || goSlow) {
        $module.loadingImage();
      }
      var url = $(this).attr('href');
      if(goSlow) {
        url = $module.find(".edit_module_link").attr('href');
      }
      $.ajaxJSON(url, (goSlow ? 'GET' : 'POST'), {collapse: collapse}, function(data) {
        if(goSlow) {
          $module.loadingImage('remove');
          var items = data;
          var next = function() {
            var item = items.shift();
            if(item) {
              modules.addItemToModule($module, item.content_tag);
              next();
            } else {
              $module.find(".context_module_items.ui-sortable").sortable('refresh');
              toggle(true);
              modules.updateProgressionState($module);
              $("#context_modules").triggerHandler('slow_load');
            }
          };
          next();
        } else {
          if(reload_entries) {
            $module.loadingImage('remove');
            for(var idx in data) {
              modules.addItemToModule($module, data[idx].content_tag);
            }
            $module.find(".context_module_items.ui-sortable").sortable('refresh');
            toggle();
            modules.updateProgressionState($module);
          }
        }
      }, function(data) {
        $module.loadingImage('remove');
      });
      if(collapse == '1' || !reload_entries) {
        toggle();
      }
    });
    $(".refresh_progressions_link").click(function(event) {
      event.preventDefault();
      $(this).addClass('refreshing');
      var $link = $(this);
      var id = $("#student_progression_dialog").find(".student.selected_side_tab:first").getTemplateData({textValues: ['id']}).id;
      if(id) {
        modules.updateProgressions(id, function() {
          $link.removeClass('refreshing');
          $link.blur();
          $("#student_progression_dialog").find(".student.selected_side_tab:first").click();
        });
      }
    });
    $("#student_progression_dialog").delegate('.student', 'click', function(event) {
      $("#student_progression_dialog").find(".selected_side_tab").removeClass('selected_side_tab');
      $(this).addClass('selected_side_tab');
      event.preventDefault();
      var id = $(this).getTemplateData({textValues: ['id']}).id;
      var $studentWithProgressions = $("#progression_list .student_" + id + ":first");
      $("#context_modules .context_module:visible").each(function() {
        var $module = $(this);
        var moduleData = $module.find(".header").getTemplateData({textValues: ['id', 'name']});
        var $row = $("#student_progression_dialog .module_" + moduleData.id);

        moduleData.progress = $studentWithProgressions.find(".progression_" + moduleData.id + ":first").getTemplateData({textValues: ['workflow_state']}).workflow_state;
        moduleData.progress = moduleData.progress || "no information";
        var type = "nothing";
        if(moduleData.progress == "unlocked") {
          type = "in_progress";
          moduleData.progress = "in progress";
        } else if(moduleData.progress == "started") {
          type = "in_progress";
          moduleData.progress = "in progress";
        } else if(moduleData.progress == "completed") {
          type = "completed";
        } else if(moduleData.progress == "locked") {
          type = "locked";
        }
        $row.find(".still_need_completing").empty();
        if(moduleData.progress == "in progress") {
          var $requirements = $("#context_module_" + moduleData.id + " .context_module_item.progression_requirement");
          var progression = $studentWithProgressions.find(".progression_" + moduleData.id).data('progression');
          var unfulfilled = [];
          $requirements.each(function() {
            var $req = $(this);
            var req = {id: $req.attr('id').substring(20)};
            if($req.hasClass('must_view_requirement')) {
              req.type = 'must_view';
            } else if($req.hasClass('min_score_requirement')) {
              req.type = 'min_score';
            } else if($req.hasClass('max_score_requirement')) {
              req.type = 'max_score';
            } else if($req.hasClass('must_contribute_requirement')) {
              req.type = 'must_contribute';
            } else if($req.hasClass('must_submit_requirement')) {
              req.type = 'must_submit';
            }
            var met = false;
            if(progression && progression.requirements_met) {
              for(var jdx = 0; jdx < progression.requirements_met.length; jdx++) {
                var compare = progression.requirements_met[jdx];
                if(compare.id == req.id && compare.type == req.type) {
                  met = true;
                }
              }
            }
            if(!met) {
              unfulfilled.push($req.find(".title:first").text());
            }
          });
          $row.find(".still_need_completing")
            .append("<b>"+I18n.t('still_needs_completing', 'Still Needs to Complete')+"</b><br/>")
            .append(unfulfilled.join("<br/>"));
        }
        $row.removeClass('locked').removeClass('in_progress').removeClass('completed')
          .addClass(type);
        moduleData.progressString = moduleData.progress;
        //I18n
        if (moduleData.progress == "completed") {
          moduleData.progress = I18n.t('progress.completed', 'Completed');
        } else if (moduleData.progress == "in_progress"){
          moduleData.progress = I18n.t('progress.in_progress', 'In progress');
        } else if (moduleData.progress == "locked"){
          moduleData.progress = I18n.t('progress.locked', 'locked');
        }
        $row.fillTemplateData({data: moduleData});
      });
    });
    $(".module_progressions_link").click(function(event) {
      event.preventDefault();
      var $dialog = $("#student_progression_dialog");
      var $student_list = $dialog.find(".student_list");
      $student_list.find(".student:not(.blank)").remove();
      $dialog.find(".side_tabs_content tbody .module:not(.blank)").remove();
      var $visible_modules = $("#context_modules .context_module:visible");
      var module_ids = [];
      $visible_modules.each(function() {
        var $mod = $(this);
        var id = $mod.attr('id').substring(15);
        module_ids.push(id);
      });
      $("#progression_list .student").each(function() {
        var $student = $dialog.find(".student.blank:first").clone(true).removeClass('blank');
        var $studentWithProgressions = $(this);
        var data = $studentWithProgressions.getTemplateData({textValues: ['name', 'id', 'current_module']});
        data.current_module = data.current_module || I18n.t('none_in_progress', "none in progress");
        $student.find("a").attr('href', '#' + data.id);
        $student.fillTemplateData({data: data});
        $student_list.append($student.show())
      });
      $visible_modules.each(function() {
        var $module = $(this);
        var moduleData = $module.find(".header").getTemplateData({textValues: ['id', 'name']});
        var $template = $dialog.find(".module.blank:first").clone(true).removeClass('blank');

        $template.addClass('module_' + moduleData.id);
        $template.fillTemplateData({data: moduleData});
        $dialog.find(".side_tabs_content tbody").append($template.show());
      });

      $("#student_progression_dialog").dialog({
        width: 800,
        open: function() {
          $(this).find(".student:not(.blank):first .name").click();
        }
      });
    });
    $(".context_module .progression_details_link").click(function(event) {
      event.preventDefault();
      var data = $(this).parents(".context_module").find(".header").getTemplateData({textValues: ['id', 'name']});
      data.module_name = data.name;
      var $dialog = $("#module_progression_dialog");
      $dialog.fillTemplateData({data: data});
      $dialog.find("ul").empty();
      $dialog.find(".progression_list").hide();
      $("#progression_list .student").each(function() { //.progressions .progression_" + data.id).each(function() {
        var $progression = $(this).find(".progressions .progression_" + data.id);
        var progressionData = $progression.getTemplateData({textValues: ['context_module_id', 'workflow_state']});
        progressionData.workflow_state = progressionData.workflow_state || "locked";
        progressionData.name = $(this).getTemplateData({textValues: ['name']}).name;
        $dialog.find("." + progressionData.workflow_state + "_list").show()
          .find("ul").show().append($("<li />").text(progressionData.name));
      });
      $("#module_progression_dialog").dialog({
        title: I18n.t('titles.student_progress', "Student Progress for Module"),
        width: 500
      });
    });
    $(document).fragmentChange(function(event, hash) {
      var module = $(hash.replace(/module/, "context_module"));
      if (module.hasClass('collapsed_module')) {
        module.find(".expand_module_link").triggerHandler('click');
      }
    });

    // from context_modules/_content
    var foundExpanded = false;
    var collapsedModules = ENV.COLLAPSED_MODULES;
    for(var idx in collapsedModules) {
      $("#context_module_" + collapsedModules[idx]).addClass('collapsed_module');
    }
    var foundModules = [];
    var $contextModules = $("#context_modules .context_module");
    if (!$contextModules.length) {
      $('#no_context_modules_message').show();
    }
    $contextModules.each(function() {
      modules.updateProgressionState($(this));
    });
    $contextModules.filter(":visible").each(function() {
      if($(this).find(".content:visible").length > 0) {
        foundExpanded = true;
      } else if(foundExpanded) {
        foundModules.push($(this));
      }
    });
    $("#context_modules").bind('slow_load', function() {
      var $module = foundModules.shift();
      if($module) {
        $module.find(".expand_module_link:first").triggerHandler('click', true);
      }
    });
  });

  return modules;
});
