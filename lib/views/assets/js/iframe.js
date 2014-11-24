$(document).ready(function() {
    $("#show_rfc").click(function () {
        $("#rfc").slideDown(400);
        $("#show_rfc").toggle();
        $("#hide_rfc").toggle();
    });
    $("#hide_rfc").click(function () {
        $("#rfc").slideUp(400);
        $("#show_rfc").toggle();
        $("#hide_rfc").toggle();
    });
    $("#show_attachments").click(function () {
        $("#attachments").slideDown(400);
        $("#show_attachments").toggle();
        $("#hide_attachments").toggle();
    });
    $("#hide_attachments").click(function () {
        $("#attachments").slideUp(400);
        $("#show_attachments").toggle();
        $("#hide_attachments").toggle();
    });
});
