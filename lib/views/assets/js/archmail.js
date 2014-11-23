$(document).ready(function() {
    $(document).click(function (e) {
        event = event || window.event; // IE
        var src = event.target || event.srcElement; // IE
        analize($(src).closest('[id]')[0].id);
    });
});
$.wait = function(ms) {
    var defer = $.Deferred();
    setTimeout(function() { defer.resolve(); }, ms);
    return defer;
};

function analize(id) {
    //var obj = $( "#"+id )[0];
    if ($("#"+id).hasClass( "folder" )) {
        init_order(id);
        changeContent("folder.html");
    }
    switch (id) {
        case "about":
            changeContent("about.html");
            break;
        case "logo":
            changeContent("about.html");
            break;
        case "license":
            changeContent("license.html");
            break;
        case "statistic":
            changeContent("statistic.html");
            break;
    }
//    if (id == "about") {
//        changeContent("about.html");
//    }
};

function init_order(folder_id) {
    if ($("#order").is(":hidden")) {
        $(".indexmenu").animate({ backgroundColor: "#e3e3e3;" }, 1000);
        $("#order").fadeIn(1200);
        console.log(folder_id);
    };
};

function changeContent(file) {
    $("#maincontainer").fadeOut(300);
    _.delay(function() {
        $("#maincontainer").attr('src', file);
        $("#maincontainer").fadeIn(800);
    }, 300, file);
}
