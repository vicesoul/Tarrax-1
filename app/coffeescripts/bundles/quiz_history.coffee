require [
  'jquery'
  'quiz_arrows'
  'quiz_inputs'
  'quiz_history'
  # 2012-11-27 rupert add comments.js
  # 'comments'
  # end
], ($, createQuizArrows, inputMethods) ->
  $ ->
    createQuizArrows()
    inputMethods.disableInputs('[type=radio], [type=checkbox]')
    inputMethods.setWidths()
