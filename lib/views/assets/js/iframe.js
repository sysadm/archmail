$(document).ready(function() {
    var is_chrome = navigator.userAgent.toLowerCase().indexOf('chrom') > -1;
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
    $('.balloon').click(function (event) {
        event = event || window.event; // IE
        var src = event.target || event.srcElement; // IE
        var filter = src.id;
        var new_li_id = 1;
        $('li.odd').removeClass("odd");
        $("li").hide();
        $("li."+filter).fadeIn(300);
        $("li").filter( function() {
            if ($(this).is(":visible")){
                var odd = false;
                if (new_li_id % 2 == 0) {
                    odd = true;
                }
                new_li_id += 1;
                return odd;
            };
        }).addClass("odd");
        $('#remove_filter').fadeIn(300);
    });
    $('#remove_filter').click(function () {
        $('#remove_filter').fadeOut(300);
        $("li").hide();
        $('li.odd').removeClass("odd");
        $('li').filter(":odd").addClass("odd");
        $("li").fadeIn(300);
    });

    $('base').remove();

    if (is_chrome) {
        $(".message").click(function () {
            $("#frame_maillist_div").hide();
            $("#framemessage").attr('src', this.id);
            $("#frame_message_div").fadeIn(300);
        });
        $(".back").click(function () {
            $("#frame_message_div").fadeOut(300);
            _.delay(function() {
                $("#frame_maillist_div").fadeIn(300);
            }, 300);
        });
    }
    else {
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
    }

});
