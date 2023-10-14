## Contribute to translations ##

Please fork this repository and sync with master if you haven't done so.

1. If you you're going to add support for a new language run `./Messages.sh lang_name` (e.g. `./Messages.sh fr` to add support for French)
2. If you want to refine translation of already supported language run `./Messages.sh lang_name` again before modifying `.po` files to ensure they have latest translatable strings.
3. Open `.po` file in any text redactor or any Language Tool(e.g. Qt Linguist).
4. Fill in `msgstr` with translated strings
5. Check if there are any `fuzzy` translations that need your attention.
6. Save

### Before committing: ###

1. Check that your translations works and looks fine(test it)
2. Run git status and check that other translations not affected by your actions.
3. Exclude .pot file from commit(if it doesn't has any major changes other that creation date)
4. In the end your commit should only contain `.po` files of your newly added/modified language. If so then add a git commit and send a pull request.

## Regenerate all translation strings: ##

If you  are an developer or you has made changes on the plasmoid, specially if you has had added some i18n strings, you need to reload all strings from the project.

For this task you simply run:

````Shell
./translation.sh
````

This script collect and update the template catalog `plasma_applet_org.kde.simpleMonitor.pot`.

If you want to update all language catalogs you need to run the script with `--upgrade-all` parameter:

````Shell
./translation.sh --update-all
````
