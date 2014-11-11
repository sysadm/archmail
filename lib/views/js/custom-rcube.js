/*
        @licstart  The following is the entire license notice for the 
        JavaScript code in this page.

        Copyright (C) 2005-2014 The Roundcube Dev Team

        The JavaScript code in this page is free software: you can redistribute
        it and/or modify it under the terms of the GNU General Public License
        as published by the Free Software Foundation, either version 3 of
        the License, or (at your option) any later version.

        The code is distributed WITHOUT ANY WARRANTY; without even the implied
        warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
        See the GNU GPL for more details.

        @licend  The above is the entire license notice
        for the JavaScript code in this page.
*/
var rcmail = new rcube_webmail();
rcmail.set_env({"task":"mail","x_frame_options":"sameorigin","standard_windows":false,"locale":"en_GB","cookie_domain":"","cookie_path":"\/","cookie_secure":true,"skin":"larry","refresh_interval":60,"session_lifetime":86400,"action":"","comm_path":".\/?_task=mail","user_id":"08266af50b5bd77cbe4a8326b866dbc9","compose_extwin":false,"date_format":"dd.mm.yy","browser_capabilities":{"pdf":"1","flash":"1","tif":"0"},"search_mods":{"*":{"subject":1,"from":1},"Sent":{"subject":1,"to":1},"Drafts":{"subject":1,"to":1},"INBOX":{"subject":1,"from":1}},"mailbox":"INBOX","pagesize":50,"delimiter":".","threading":true,"threads":true,"reply_all_mode":0,"preview_pane_mark_read":0,"quota":true,"drafts_mailbox":"Drafts","trash_mailbox":"Trash","junk_mailbox":"Junk","read_when_deleted":true,"display_next":true,"unreadwrap":"%s","collapsed_folders":"","mailboxes":{"INBOX":{"id":"INBOX","name":"Inbox","virtual":false,"class":"inbox"},"INBOX.Not work":{"id":"INBOX.Not work","name":"Not work","virtual":false},"Drafts":{"id":"Drafts","name":"Drafts","virtual":false,"class":"drafts"},"Sent":{"id":"Sent","name":"Sent","virtual":false,"class":"sent"},"Sent.test":{"id":"Sent.test","name":"test","virtual":false},"Trash":{"id":"Trash","name":"Deleted Items","virtual":false,"class":"trash"},"Deleted Messages":{"id":"Deleted Messages","name":"Deleted Messages","virtual":false},"Sent Messages":{"id":"Sent Messages","name":"Sent Messages","virtual":false},"Sent Messages.test2":{"id":"Sent Messages.test2","name":"test2","virtual":false}},"mailboxes_list":["INBOX","INBOX.Not work","Drafts","Sent","Sent.test","Trash","Deleted Messages","Sent Messages","Sent Messages.test2"],"col_movable":true,"autoexpand_threads":0,"sort_col":"date","sort_order":"DESC","messages":[],"listcols":["threads","subject","status","fromto","size","flag","attachment"],"disabled_sort_col":false,"disabled_sort_order":false,"coltypes":{"threads":{"className":"threads","id":"rcmthreads","label":"","sortable":false},"subject":{"className":"subject","id":"rcmsubject","label":"Subject","sortable":true},"status":{"className":"status","id":"rcmstatus","label":"","sortable":false},"fromto":{"className":"fromto","id":"rcmfromto","label":"From","sortable":true},"size":{"className":"size","id":"rcmsize","label":"Size","sortable":true},"flag":{"className":"flag","id":"rcmflag","label":"","sortable":false},"attachment":{"className":"attachment","id":"rcmattachment","label":"","sortable":false}},"blankpage":"skins\/larry\/watermark.html","contentframe":"messagecontframe","max_filesize":2097152,"filesizeerror":"The uploaded file exceeds the maximum size of 2.0 MB.","request_token":"943c5a66d3f70dd60bafa03e4c2fee00"});
rcmail.add_label({"loading":"Loading...","servererror":"Server Error!","connerror":"Connection Error (Failed to reach the server)!","requesttimedout":"Request timed out","refreshing":"Refreshing...","windowopenerror":"The popup window was blocked!","checkingmail":"Checking for new messages...","deletemessage":"Delete message","movemessagetotrash":"Move message to \"Deleted Items","movingmessage":"Moving message(s)...","copyingmessage":"Copying message(s)...","deletingmessage":"Deleting message(s)...","markingmessage":"Marking message(s)...","copy":"Copy","move":"Move","quota":"Disk usage","replyall":"Reply all","replylist":"Reply list","stillsearching":"Still searching...","flagged":"Flagged","unflagged":"Not Flagged","unread":"Unread","deleted":"Deleted","replied":"Replied","forwarded":"Forwarded","priority":"Priority","withattachment":"With attachment","fileuploaderror":"File upload failed.","searching":"Searching...","purgefolderconfirm":"Do you really want to delete all messages in this folder?","deletemessagesconfirm":"Do you really want to delete the selected message(s)?","from":"From","to":"To","selectimportfile":"Please select a file to upload.","importwait":"Importing, please wait..."});
rcmail.gui_container("topline-left","topline-left");
rcmail.gui_container("topline-center","topline-center");
rcmail.gui_container("topline-right","topline-right");
rcmail.gui_container("taskbar","taskbar");
rcmail.gui_container("toolbar","mailtoolbar");
rcmail.gui_container("forwardmenu","forwardmenu");
rcmail.gui_container("replyallmenu","replyallmenu");
rcmail.gui_container("messagemenu","messagemenu");
rcmail.gui_container("markmenu","markmessagemenu");
rcmail.gui_container("listcontrols","listcontrols");
rcmail.gui_container("mailboxoptions","mailboxoptionsmenu");
rcmail.register_button('logout', 'rcmbtn101', 'link', '', '', '');
rcmail.register_button('mail', 'rcmbtn102', 'link', '', 'button-mail button-selected', '');
rcmail.register_button('addressbook', 'rcmbtn103', 'link', '', 'button-addressbook button-selected', '');
rcmail.register_button('settings', 'rcmbtn104', 'link', '', 'button-settings button-selected', '');
rcmail.register_button('logout', 'rcmbtn105', 'link', '', 'button-logout', '');
rcmail.register_button('checkmail', 'rcmbtn106', 'link', 'button checkmail', 'button checkmail pressed', '');
rcmail.register_button('compose', 'rcmbtn107', 'link', 'button compose', 'button compose pressed', '');
rcmail.register_button('reply', 'rcmbtn108', 'link', 'button reply', 'button reply pressed', '');
rcmail.register_button('reply-all', 'rcmbtn109', 'link', 'button reply-all', 'button reply-all pressed', '');
rcmail.register_button('forward', 'rcmbtn110', 'link', 'button forward', 'button forward pressed', '');
rcmail.register_button('delete', 'rcmbtn111', 'link', 'button delete', 'button delete pressed', '');
rcmail.register_button('forward-inline', 'rcmbtn112', 'link', 'forwardlink active', '', '');
rcmail.register_button('forward-attachment', 'rcmbtn113', 'link', 'forwardattachmentlink active', '', '');
rcmail.register_button('reply-all', 'rcmbtn114', 'link', 'replyalllink active', '', '');
rcmail.register_button('reply-list', 'rcmbtn115', 'link', 'replylistlink active', '', '');
rcmail.register_button('print', 'rcmbtn116', 'link', 'icon active', '', '');
rcmail.register_button('download', 'rcmbtn117', 'link', 'icon active', '', '');
rcmail.register_button('edit', 'rcmbtn118', 'link', 'icon active', '', '');
rcmail.register_button('viewsource', 'rcmbtn119', 'link', 'icon active', '', '');
rcmail.register_button('move', 'rcmbtn120', 'link', 'icon active', '', '');
rcmail.register_button('copy', 'rcmbtn121', 'link', 'icon active', '', '');
rcmail.register_button('open', 'rcmbtn122', 'link', 'icon active', '', '');
rcmail.register_button('mark', 'rcmbtn123', 'link', 'icon active', '', '');
rcmail.register_button('mark', 'rcmbtn124', 'link', 'icon active', '', '');
rcmail.register_button('mark', 'rcmbtn125', 'link', 'icon active', '', '');
rcmail.register_button('mark', 'rcmbtn126', 'link', 'icon active', '', '');
rcmail.gui_object('search_filter', 'messagessearchfilter');
rcmail.register_button('menu-open', 'searchmenulink', 'link', '', '', '');
rcmail.gui_object('qsearchbox', 'quicksearchbox');
rcmail.register_button('reset-search', 'searchreset', 'link', '', '', '');
rcmail.gui_object('mailboxlist', 'mailboxlist');
rcmail.gui_object('quotadisplay', 'quotadisplay');
rcmail.gui_object('messagelist', 'messagelist');
rcmail.register_button('set-listmode', 'maillistmode', 'link', 'iconbutton listmode', '', '');
rcmail.register_button('set-listmode', 'mailthreadmode', 'link', 'iconbutton threadmode', '', '');
rcmail.gui_object('countdisplay', 'rcmcountdisplay');
rcmail.register_button('firstpage', 'rcmbtn127', 'link', 'button firstpage', 'button firstpage pressed', '');
rcmail.register_button('previouspage', 'rcmbtn128', 'link', 'button prevpage', 'button prevpage pressed', '');
rcmail.register_button('nextpage', 'rcmbtn129', 'link', 'button nextpage', 'button nextpage pressed', '');
rcmail.register_button('lastpage', 'rcmbtn130', 'link', 'button lastpage', 'button lastpage pressed', '');
rcmail.register_button('move', 'rcmbtn131', 'link', 'active', '', '');
rcmail.register_button('copy', 'rcmbtn132', 'link', 'active', '', '');
rcmail.register_button('expunge', 'rcmbtn133', 'link', 'active', '', '');
rcmail.register_button('purge', 'rcmbtn134', 'link', 'active', '', '');
rcmail.register_button('import-messages', 'rcmbtn135', 'link', 'active', '', '');
rcmail.register_button('settings.folders', 'rcmbtn136', 'link', 'active', '', '');
rcmail.register_button('select-all', 'rcmbtn137', 'link', 'icon active', '', '');
rcmail.register_button('select-all', 'rcmbtn138', 'link', 'icon active', '', '');
rcmail.register_button('select-all', 'rcmbtn139', 'link', 'icon active', '', '');
rcmail.register_button('select-all', 'rcmbtn140', 'link', 'icon active', '', '');
rcmail.register_button('select-all', 'rcmbtn141', 'link', 'icon active', '', '');
rcmail.register_button('select-none', 'rcmbtn142', 'link', 'icon active', '', '');
rcmail.register_button('expand-all', 'rcmbtn143', 'link', 'icon active', '', '');
rcmail.register_button('expand-unread', 'rcmbtn144', 'link', 'icon active', '', '');
rcmail.register_button('collapse-all', 'rcmbtn145', 'link', 'icon active', '', '');
rcmail.register_button('menu-save', 'listmenusave', 'input', '', '', '');
rcmail.register_button('menu-close', 'listmenucancel', 'input', '', '', '');
rcmail.gui_object('importform', 'uploadformFrm');
rcmail.register_button('import-messages', 'rcmbtn146', 'input', '', '', '');
rcmail.gui_object('message', 'messagestack');

