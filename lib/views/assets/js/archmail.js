$(document).ready(function() {
    var current_folder_path="";
    $(document).click(function (event) {
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
        current_folder_path=folder_path[id];
        changeContent(current_folder_path+"threaded.html");
    }
    if ($("#"+id).hasClass( "message" )) {
        init_order(id);
        changeContent(current_folder_path+id);
    }
    switch (id) {
        case "about":
            changeContent("about.html");
            break;
        case "logo":
            changeContent("statistic.html");
            break;
        case "license":
            changeContent("license.html");
            break;
        case "statistic":
            changeContent("statistic.html");
            break;
        case "threaded":
            changeContent(current_folder_path+"threaded.html");
            break;
        case "date":
            changeContent(current_folder_path+"date.html");
            break;
        case "subject":
            changeContent(current_folder_path+"subject.html");
            break;
        case "author":
            changeContent(current_folder_path+"author.html");
            break;
        case "attachment":
            changeContent(current_folder_path+"attachment.html");
            break;
    }
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
        $(".affix-content").scrollTop(0);
        $("#maincontainer").fadeIn(800);
    }, 300, file);
}
