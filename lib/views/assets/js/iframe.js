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

    $(".message").click(function () {
        $("#frame_maillist_div").hide();
        $("#framemessage").attr('src', this.id);
        $("#frame_message_div").show("slide", { direction: "right" }, 300);
    });

    $(".back").click(function () {
        $("#frame_message_div").hide("slide", { direction: "right" }, 300);
        _.delay(function() {
            $("#frame_maillist_div").show("slide", { direction: "left" }, 300);
        }, 300);
    });
});
