/*******************************************************************************
 * code from https://github.com/TimLang/jquery-plugins/edit/master/org.tim.jquery/jquery.ui.easy-dialog.js
 *
 * based on jquery 1.4.4, jquery ui 1.7.3, it's a easy dialog.
 * 
 * @author Tim_Lang
 * 
 * @since 2011.3
 */
define(['jquery',
    'jqueryui/dialog'
], function($) {

	$.fn.easyDialog = function(options, dialogType) {
		var settings = options || {};
		var opts = $.fn.extend(true, {},
		$.fn.easyDialog.defaults, settings);

		if (settings.content === undefined) {
			var dialog = this;
		} else {
			var dialog = this.html(opts.content);
		}

		if (dialogType === 'confirm' || options === 'confirm') {
			var buttons = [{
				text: opts.confirmButton,
				click: function() {
					opts.confirmCallback.call(this);
					$(this).dialog('close');
				}
			},
			{
				text: opts.cancelButton,
				click: function() {
					$(this).dialog('close');
				}
			}]
			return dialog.dialog({
				modal: opts.modal,
				title: opts.title,
				width: opts.width,
				buttons: buttons,
				open: opts.openFunction
			});
		}
		if (options === undefined || options !== 'confirm') {
			if (settings.width === undefined) opts.width = 300;
			return dialog.dialog({
				modal: opts.modal,
				title: opts.title,
				width: opts.width,
				open: function() {
					setTimeout(function() {
						dialog.dialog('close')
					},
					1500);
				},
				buttons: []
			});
		}

	}

	$.fn.easyDialog.defaults = {
		url: '',
		title: '提示窗口',
		content: '',
		confirmButton: '确认',
		cancelButton: '取消',
		confirmCallback: function() {},
		modal: true,
		width: 'auto',
		height: 'auto',
		global: true,
		isCloseDialog: true,
		openFunction: function() {}
	}
});

