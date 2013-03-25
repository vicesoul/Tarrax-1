define [
  'Backbone'
  'underscore'
  'i18n!account'
], (Backbone, _, I18n) ->
  class Account extends Backbone.Model

    errorMap:
      name:
        blank: I18n.t('errors.required', 'Required')
        taken: I18n.t('errors.taken', 'Taken')
      user_role:
        blank: I18n.t('errors.required', 'Required')
      user_mobile:
        blank: I18n.t('errors.required', 'Required')
        invalid_mobile: I18n.t('errors.invalid_mobile', 'Invalid Mobile')
      school_category:
        blank: I18n.t('errors.required', 'Required')
      school_scale:
        blank: I18n.t('errors.required', 'Required')
      captcha:
        invalid_code: I18n.t('errors.invalid_code', 'Invalid Code')
