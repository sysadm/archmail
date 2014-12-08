## About Archmail

Archmail is a small software to archive your IMAP mailbox. It was created for internal purpose
of [Multitel A.S.B.L.](http://www.multitel.be/) (non-profit organisation) by Jerzy Sładkowski to have IMAP mailbox backup,
absolutely independent from any servers. Idea was to create a folder with html files (each email
in a separate html) and attachments. In addition, it should have been created html indexes to have
ordered in specific way lists of emails (threaded, date, subject, author or emails with attachments only).
Folder with that backup can be burn, for example on DVD. And for access to your mail archive you have to use
browser only, nothing else. All modern browser must be supported. That was a main idea.

The author was inspired by the [hypermail](http://www.hypermail-project.org/). Well, hypermail
can create mailists, but only from unix mbox, can't use IMAP with multiple folders that can also be nested.

Archmail is compatible with [Gmail](https://www.gmail.com/). Gmail also offer the backup of your mails, for example
[first](https://www.google.com/settings/takeout/custom/gmail,calendar) or
[second](https://code.google.com/p/gmail-backup-com/) solution, but like an
unix mailbox of specific folder(label) in your mailbox. Even third party solution, like [Gmvault](http://gmvault.org/) have the
same approach and the same problem. That programs just generate typical "backup". You can save everything and restore it
on server (eventually open in specific mailer program). Archmail instead of typical backup create full-featured offline
"mailer program". You can find and access any email in any folder really fast, easy and in many different ways.

During the work somehow came out that was quite an interesting application that generate html visually pleasing.
At least, so it seems for the author :)

[![archmail screenshot1](https://github.com/sysadm/archmail/raw/master/example/am_screenshot1.jpg)](#features)

Example of colorized tags. Standard IMAP account and Gmail:

[![tag example](https://github.com/sysadm/archmail/raw/master/example/tag_example.jpg)](#features)

Features
--------

* easy install and using. You can use it in your script also with silent mode and write all to log file
* return normal unix exit code supported. 0 for success, all other - errors.
* you can create config in interactive mode instead of edit it manually
* it's possible to interrupt archmail any moment with `ctrl+c` and continue with option `-c`
* possibility to backup defined IMAP folder with (default option) or without recursion
* archmail has no limits on nested folders. Messages also are represented like an unlimited tree
* really EASY access to any email or attachment. Each folder has indexes with mail grouped and ordered by date, subject or author
* it save mail flags and labels (X-GM-Label in case of Gmail) like a colorized tags. You can filter your mail by tags by click on selected tag.
* as a backend author use sqlite for some internal Multitel reason. But you can use any other database which supported by ActiveRecord as well.


## Getting Started

1. Install sqlite development package
2. Install [RVM](http://rvm.io/) and source it (better way: add `source ~/.rvm/scripts/rvm` to your .profile or .bashrc for autoload).
3. `git clone git@github.com:sysadm/archmail.git`
4. `cd archmail && bundle install`
5. use it!


## Using

Full command line help:

        ./archmail.rb -h


## License

Archmail is released under the [GNU General Public License](http://www.gnu.org/licenses/).


## Contributing

Since this is a completely free software under GPL license - **feel free to contribute**, improve its source code or give me constructive criticism.
Your git pull request will be pleasantly welcome.


#####Thanks a lot for using!
**Author**
