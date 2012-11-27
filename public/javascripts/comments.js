define([
    'INST' /* INST */,
    'i18n!gradebook',
    'jquery' /* $ */
], function(INST, I18n, $) {
    $(document).ready(function(){
        var $question_holder  = $("#questions .question_holder ");

        $("<svg></svg>").attr({
            "width":"100%",
            "height":"100%",
            "id":"drawing"
        }).prependTo($question_holder);

        $("#drawing").mousedown(function(){

        })


    })




});